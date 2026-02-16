CREATE DATABASE order_service_development;
CREATE DATABASE order_service_test;
CREATE DATABASE customer_service_development;
CREATE DATABASE customer_service_test;
GRANT ALL PRIVILEGES ON DATABASE order_service_development TO postgres;
GRANT ALL PRIVILEGES ON DATABASE order_service_test TO postgres;
GRANT ALL PRIVILEGES ON DATABASE customer_service_development TO postgres;
GRANT ALL PRIVILEGES ON DATABASE customer_service_test TO postgres;
