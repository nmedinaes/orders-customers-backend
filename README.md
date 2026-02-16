# Pedidos & Clientes - Microservicios

Aplicación backend compuesta por dos microservicios en Rails: **Order Service** (Servicio de Pedidos) y **Customer Service** (Servicio de Clientes). El Order Service se comunica con el Customer Service mediante HTTP y utiliza RabbitMQ para actualizaciones basadas en eventos.

<img width="1227" height="262" alt="image" src="https://github.com/user-attachments/assets/e509e865-f329-4b6c-b504-f369657d827a" />
<img width="866" height="543" alt="image" src="https://github.com/user-attachments/assets/541f218b-aec3-4225-b1f1-43f416ce3360" />
<img width="949" height="468" alt="image" src="https://github.com/user-attachments/assets/1d1c524b-cb1d-47d1-b5b2-a86d5deb126d" />
<img width="1092" height="280" alt="image" src="https://github.com/user-attachments/assets/e8dd6e82-b819-4ac6-bccc-df712d4d6a01" />

## Arquitectura
<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/6b3b742c-b117-464f-82c2-399410db3326" />

### Flujo de trabajo

1. **Crear pedido**: El cliente envía un POST al Order Service → el Order Service consulta al Customer Service para validar que el cliente existe → guarda el pedido → publica el evento `order.created` en RabbitMQ → devuelve el pedido con los datos del cliente.

2. **Procesamiento de eventos**: El consumer del Customer Service escucha el evento `order.created` → incrementa el campo `orders_count` del cliente correspondiente.

3. **Listar pedidos**: El cliente consulta los pedidos por `customer_id` en el Order Service.

## Requisitos

- Docker
- Docker Compose

## Inicio rápido

```bash
docker compose up --build
```

Al ejecutar este comando se crean automáticamente las bases de datos, se aplican las migraciones (tablas) y se cargan los clientes iniciales del seed en el Customer Service. No hace falta ejecutar migraciones ni seeds a mano.

Esto levanta:

- **PostgreSQL** (puerto 5432) - Base de datos
- **RabbitMQ** (puertos 5672 y 15672) - Cola de mensajes. La interfaz web está en http://localhost:15672 (usuario/contraseña: guest/guest)
- **Customer Service** (http://localhost:3001) - API de clientes
- **Order Service** (http://localhost:3002) - API de pedidos
- **Order Event Consumer** - Proceso en segundo plano que procesa eventos de RabbitMQ

## Endpoints de la API

### Order Service (puerto 3002)

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | /api/v1/orders?customer_id=1&page=1&per_page=20 | Lista pedidos de un cliente (paginado) |
| GET | /api/v1/orders/:id | Obtiene un pedido por ID |
| POST | /api/v1/orders | Crea un nuevo pedido |

Ejemplo de cuerpo para crear pedido:

```json
{
  "order": {
    "customer_id": 1,
    "product_name": "Widget",
    "quantity": 2,
    "price": 29.99,
    "status": "pending"
  }
}
```

Estados válidos: `pending`, `processing`, `shipped`, `delivered`, `cancelled`

### Customer Service (puerto 3001)

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | /api/v1/customers | Lista todos los clientes |
| GET | /api/v1/customers/:id | Obtiene un cliente (customer_name, address, orders_count) |

## Ejecutar pruebas

Levantar primero la infraestructura:

```bash
docker compose up -d postgres rabbitmq
```

Ejecutar los tests (el script `bin/test` aplica migraciones de test si hace falta):

```bash
# Customer Service
docker compose run --rm customer_service bash bin/test

# Order Service
docker compose run --rm order_service bash bin/test
```

## Desarrollo local (sin Docker)

Requisitos: Ruby 3.2, PostgreSQL, RabbitMQ

1. Crear las bases de datos: `order_service_development`, `order_service_test`, `customer_service_development`, `customer_service_test`
2. Configurar variables de entorno: `CUSTOMER_SERVICE_URL`, `RABBITMQ_HOST`, `DATABASE_URL`
3. Ejecutar migraciones y seeds en cada servicio
4. Iniciar Customer Service en el puerto 3001 y Order Service en el 3002
5. Ejecutar el consumer: `cd customer_service && bundle exec rake orders:consumer`

## Estructura del proyecto

```
.
├── order_service/                    # Servicio de Pedidos (Rails API)
│   ├── app/
│   │   ├── controllers/api/v1/orders_controller.rb
│   │   ├── models/order.rb
│   │   └── services/
│   │       ├── customer_service_client.rb   # Cliente HTTP al Customer Service
│   │       └── order_event_publisher.rb     # Publica eventos en RabbitMQ
│   ├── bin/
│   │   ├── docker-entrypoint
│   │   └── test                        # Script para ejecutar pruebas
│   ├── db/
│   │   └── migrate/
│   ├── spec/
│   │   ├── factories/orders.rb
│   │   ├── models/order_spec.rb
│   │   ├── requests/orders_spec.rb
│   │   ├── services/customer_service_client_spec.rb
│   │   └── support/
│   ├── Dockerfile.dev
│   └── Gemfile
├── customer_service/                 # Servicio de Clientes (Rails API)
│   ├── app/
│   │   ├── controllers/api/v1/customers_controller.rb
│   │   ├── models/customer.rb
│   │   └── services/order_event_consumer.rb  # Consume eventos de RabbitMQ
│   ├── bin/
│   │   ├── docker-entrypoint         # db:prepare + db:seed al arrancar
│   │   └── test                      # Script para ejecutar pruebas
│   ├── db/
│   │   ├── migrate/
│   │   └── seeds.rb                  # Clientes predefinidos
│   ├── lib/tasks/
│   │   └── consumer.rake             # Tarea orders:consumer
│   ├── spec/
│   │   ├── factories/customers.rb
│   │   ├── models/customer_spec.rb
│   │   ├── requests/customers_spec.rb
│   │   └── services/order_event_consumer_spec.rb
│   ├── Dockerfile.dev
│   └── Gemfile
├── docker/
│   └── postgres/init.sql             # Creación de bases de datos al iniciar
└── docker-compose.yml
```

## Verificar que todo funciona

1. Crear un pedido desde el frontend o con cURL
2. Revisar la tabla `orders` en la BD `order_service_development` — debe aparecer el pedido
3. Revisar la tabla `customers` en la BD `customer_service_development` — el campo `orders_count` del cliente debe haberse incrementado

Si ambos ocurren, la comunicación HTTP entre servicios y el flujo de eventos con RabbitMQ están funcionando correctamente.
