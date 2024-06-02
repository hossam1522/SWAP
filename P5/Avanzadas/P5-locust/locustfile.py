from locust import HttpUser, TaskSet, task, between

class P5_hossam(TaskSet):
    def on_start(self):
        # Tarea que se ejecuta cuando un usuario se inicia
        self.login()

    def login(self):
        response = self.client.post("/wp-login.php", data={"log": "admin", "pwd": "admin_password"}, verify=False)
        self.auth_token = response.cookies.get('wordpress_logged_in', '')

    @task
    def load_index(self):
        self.client.get("/", verify=False)

    @task
    def navigate_pages(self):
        # Simular navegación por varias páginas
        self.client.get("/about", verify=False)
        self.client.get("/contact", verify=False)
        self.client.get("/services", verify=False)

    @task
    def create_post(self):
        # Simular creación de un nuevo post (necesitarás un plugin o endpoint personalizado para esto)
        self.client.post("/wp-json/wp/v2/posts", json={"title": "New Post", "content": "This is the content of the new post"}, headers={"Authorization": f"Bearer {self.auth_token}"}, verify=False)

    @task
    def insert_comment(self):
        # Simular inserción de un comentario en un post existente
        self.client.post("/wp-comments-post.php", data={"comment_post_ID": 1, "comment": "This is a comment"}, headers={"Authorization": f"Bearer {self.auth_token}"}, verify=False)

    @task
    def search_content(self):
        # Simular ejecución de una búsqueda
        self.client.get("/?s=example", verify=False)

    @task
    def load_dashboard(self):
        # Simular carga del panel de control de un usuario autenticado
        self.client.get("/wp-admin", headers={"Authorization": f"Bearer {self.auth_token}"}, verify=False)

class P5_usuarios(HttpUser):
    tasks = [P5_hossam]
    wait_time = between(1, 5)
