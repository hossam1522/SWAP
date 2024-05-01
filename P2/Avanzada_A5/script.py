#!/usr/bin/env python

import docker
import subprocess
import shutil
import os

# Configura el cliente de Docker
client = docker.from_env()

# Ruta al archivo de respaldo de nginx.conf
nginx_conf_backup = "P2-hossam-nginx/backup"

# Función para obtener métricas de un contenedor
def get_container_stats(container_id):
    container = client.containers.get(container_id)
    stats = container.stats(stream=False)
    return stats

# Función para calcular la carga promedio de CPU de todos los contenedores
def calculate_average_cpu_usage():
    containers = client.containers.list()
    total_cpu_usage = 0
    total_containers = 0
    for container in containers:
        stats = get_container_stats(container.id)
        cpu_percentage = stats['cpu_stats']['cpu_usage']['total_usage'] / stats['cpu_stats']['system_cpu_usage'] * 100
        total_cpu_usage += cpu_percentage
        total_containers += 1
    if total_containers > 0:
        return total_cpu_usage / total_containers
    else:
        return 0

# Función para obtener una lista de direcciones IP asignadas a los contenedores existentes
def get_assigned_ips():
    assigned_ips = set()
    containers = client.containers.list()
    for container in containers:
        container_info = container.attrs
        if "NetworkSettings" in container_info and "IPAddress" in container_info["NetworkSettings"]:
            assigned_ips.add(container_info["NetworkSettings"]["IPAddress"])
    return assigned_ips

# Función para obtener una dirección IP disponible dentro del rango de la red
def get_available_ip():
    used_ips = get_assigned_ips()
    for i in range(2, 255):  # Suponiendo que las IPs disponibles comiencen desde .2 y terminen en .254
        ip_address = f"192.168.10.{i}"  # Cambia esto según tu configuración de red
        if ip_address not in used_ips:
            # Verificar si la dirección IP está disponible
            process = subprocess.run(["ping", "-c", "1", ip_address], capture_output=True)
            if process.returncode != 0:
                return ip_address
    return None  # Si no se encuentra ninguna IP disponible

# Función para crear un nuevo contenedor de servidor web
def create_new_web_server():
    # Ejemplo: crea un nuevo contenedor de servidor web utilizando la imagen hossam-apache-image:p2
    available_ip = get_available_ip()
    if available_ip:
        # Define la ruta del volumen en el host y en el contenedor
        current_directory = os.getcwd()
        host_volume_path = "P2-hossam-nginx/web_hossam"
        container_volume_path = "/var/www/html"

        # Crea el contenedor sin conectarlo a ninguna red
        new_container = client.containers.create("hossam-apache-image:p2", detach=True, volumes={os.path.join(current_directory, host_volume_path): {'bind': container_volume_path, 'mode': 'rw'}})

        # Obtiene la red
        network = client.networks.get('red_web')

        # Conecta el contenedor a la red
        network.connect(new_container, ipv4_address=available_ip)

        #Ejecuta un comando dentro del contenedor para configurar la dirección IP
        command = f'ifconfig eth0 {available_ip} netmask 255.255.255.0'

        # Inicia el contenedor
        new_container.start()
        new_container.exec_run(command)

        #return new_container.id
        return available_ip
    else:
        return None  # Si no se encuentra una IP disponible, devuelve None

def get_container_ip(container_id):
    container = client.containers.get(container_id)
    return container.attrs['NetworkSettings']['IPAddress']

# Función para agregar un nuevo servidor al bloque upstream en nginx.conf
def add_server_to_upstream(ip_address):
    nginx_conf_file = "P2-hossam-nginx/nginx.conf"
    new_line = f"    server {ip_address}:80;\n"
    with open(nginx_conf_file, "r") as f:
        lines = f.readlines()
    for i, line in enumerate(lines):
        if "upstream backend_hossam {" in line:
            lines.insert(i + 1, new_line)
            break
    with open(nginx_conf_file, "w") as f:
        f.write("".join(lines))

# Función para restaurar el archivo nginx.conf desde el archivo de respaldo
def restore_nginx_conf_from_backup():
    shutil.copy(nginx_conf_backup, "P2-hossam-nginx/nginx.conf")

# Función para ajustar la configuración del balanceador de carga en nginx.conf
def adjust_load_balancer_config():

    # Verificar si el contenedor del balanceador está corriendo
    balanceador_running = False
    for container in client.containers.list():
        if container.name == "balanceador":
            balanceador_running = True
            break

    # Si el balanceador no está corriendo, detener y eliminar todos los contenedores y restaurar el archivo nginx.conf desde el archivo de respaldo
    if not balanceador_running:
        for container in client.containers.list():
            container.stop()
            container.remove()
        restore_nginx_conf_from_backup()
        return

    average_cpu_usage = calculate_average_cpu_usage()
    # Si no se detecta ningún contenedor, restaura el archivo nginx.conf desde el archivo de respaldo
    if average_cpu_usage == 0:
        restore_nginx_conf_from_backup()
    else:
        # Ejemplo de lógica de escalado: si la carga promedio de CPU supera el 80%, crea y agrega un nuevo servidor web al balanceador de carga
        if average_cpu_usage > 0:
            #new_container_id = create_new_web_server()
            #new_container_ip = get_container_ip(new_container_id)
            new_container_ip = create_new_web_server()
            # Agrega una nueva línea al archivo nginx.conf con la dirección IP del nuevo servidor web
            add_server_to_upstream(new_container_ip)
        # Ejemplo: si la carga promedio de CPU es inferior al 10%, elimina el último servidor web del balanceador de carga
        elif average_cpu_usage < 0:
            # Verifica si hay más de un servidor en nginx.conf
            num_servers = subprocess.run(["grep", "-c", "server ", "P2-hossam-nginx/nginx.conf"], capture_output=True, text=True)
            num_servers = int(num_servers.stdout.strip())
            if num_servers > 1:
                # Obtiene el ID del último servidor web en nginx.conf
                last_server_id = subprocess.run(["grep", "-o", "server [0-9.]*:80", "P2-hossam-nginx/nginx.conf"], capture_output=True, text=True)
                last_server_id = last_server_id.stdout.strip().split(':')[-2]  # Obtiene el ID del servidor
                last_server_id = last_server_id.split(' ')[1]
                # Leer el contenido actual del archivo nginx.conf
                with open("P2-hossam-nginx/nginx.conf", "r") as f:
                    lines = f.readlines()
                # Buscar la línea que coincide con el servidor específico y eliminarla
                updated_lines = []
                server_removed = False
                for line in lines:
                    if not server_removed and f"    server {last_server_id}:80;" in line:
                        server_removed = True
                        continue
                    updated_lines.append(line)
                # Escribir el contenido actualizado en el archivo nginx.conf
                with open("P2-hossam-nginx/nginx.conf", "w") as f:
                    f.write("".join(updated_lines))

        # Luego, recarga la configuración del balanceador de carga (asumiendo que Nginx se está utilizando como balanceador de carga)
        subprocess.run(["sudo","docker", "exec", "balanceador", "nginx", "-s", "reload"])

# Ejecuta la función para ajustar la configuración del balanceador de carga
adjust_load_balancer_config()
