🐳 Inception — Docker Infrastructure Project
This project is about building a secure and modular web infrastructure using Docker and docker-compose, all inside a virtual machine. It's designed to introduce modern system administration concepts with a hands-on approach.

 Stack & Requirements
 
   OS: Alpine or Debian (latest-1)
   
   Docker & docker-compose
   
   Everything built from scratch — no prebuilt images, no DockerHub
   
   TLSv1.2 or TLSv1.3 only
   
   All containers must restart on crash
   
   No infinite loops (tail -f, sleep, etc.)

Services

  nginx → with TLS as a secure entrypoint (port 443 only)
  
  wordpress → PHP-FPM setup (no nginx inside)
  
  mariadb → stores WordPress data
  
  2 named volumes (database & WordPress files)
  
  Custom docker network

Security & Configuration

  Custom domain: login.42.fr → points to local IP
  
  Secrets & passwords are stored outside Dockerfiles (use .env + secrets/)

  No hardcoded credentials

  Proper use of environment variables
