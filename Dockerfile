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

# Etapa III: Builder

# Paso 1: Empezar desde runtime:
FROM development AS builder

# Paso 2: Copio el resto del codigo:
ADD . /usr/src

# Paso 3: Compilar los assets de la aplicacion
RUN export DATABASE_URL=postgres://postgres@example.com:5432/fakedb \
    SECRET_KEY_BASE=0000000000000000000000000000000000 \
    RAILS_ENV=production && \
    rails assets:precompile

# Paso 4: Eliminar las librerias de ruby que no queremos en produccion:
RUN bundle config without development:test && bundle clean && rm -rf tmp/*

# Etapa IV: Desplegable (deployable)

FROM runtime AS deployable

# Paso 2: copiar las librerias de ruby que hayan quedado despues de borrar
# las que no se utilizan en la etapa anterior:
COPY --from=builder /usr/local/bundle /usr/local/bundle

# Paso 3: Copiar el codigo de la app junto con el codigo compilado y
# minificado de javascript:
COPY --from=builder /usr/src /usr/src

# Paso 4: Configurar la app para correr en modo "production":
ENV RAILS_ENV=production RACK_ENV=production

# Paso 5: 

CMD ["puma"]
