#!/bin/sh

# Realiza un benchmark al balanceador de carga usando http
ab -n 10000 -c 100 http://192.168.10.50:80/
# Realiza un benchmark al balanceador de carga usando https
ab -n 10000 -c 100 https://192.168.10.50:443/