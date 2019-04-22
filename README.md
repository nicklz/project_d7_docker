# Installation Instructions (Drupal 7)

1. Install https://docs.docker.com/install/
2. git clone git@github.com:nicklz/project_d7_docker.git projectd7
3. cd projectd7
4. cp .env.example .env && vi .env (Configure fields here)
5. make install && make up && make sync (repeat make up && make sync if this fails)
6. make rsync (the ctrl + Z if you don't want to watch the rsync output)
7. Add 127.0.0.1 local.projectd7.com to hosts file
8. Visit project website entered in .env file (example: local.projectd7.com:30003)

or git clone git@github.com:nicklz/project_docker.git projectd7 && cd projectd7 && cp .env.example .env && make install && make up && make up && make sync && make rsync

