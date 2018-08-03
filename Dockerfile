# Etapa 1: Dependencias de Ejecucion:

# Paso 1: Empezar desde Ruby:
FROM ruby:alpine AS runtime

# Paso 2: Definir el directorio de trabajo:
WORKDIR /usr/src

# Paso 3: Definir variables de entorno:
ENV HOME /usr/src
ENV PATH /usr/src/bin:$PATH

# Paso 4: Instalar paquetes de dependencias de ejecucion
RUN apk add --no-cache ca-certificates less libpq nodejs openssl tzdata

# Etapa II: Dependencias de de Desarrollo

# Paso 1: Empezar con la imagen generada en la etapa 1:
FROM runtime AS development

# 2: Instalar paquetes que son dependencias de desarrollo (compiladores,
# headers de librerías, manejadores de dependencias, etc):
RUN apk add --no-cache \
    build-base \
    chromium \
    chromium-chromedriver \
    git \
    postgresql-dev \
    yarn

# 3: Instalar el paquete de node 'check-dependencies':
RUN npm install -g check-dependencies

# 4: Copiar las listas de librerías de ruby requeridas por la app
ADD Gemfile* /usr/src/

# 5: Instalar las librerías de ruby requeridas por la aplicación (desarrollo,
# test y producción):
RUN bundle install --jobs=4 --retry=3

# 6: Definir el comando default:
CMD ["rails", "server", "-b", "0.0.0.0"]


