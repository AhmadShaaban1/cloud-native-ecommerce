graph TB
    subgraph "User Access"
        User[👤 Users]
        Browser[🌐 Web Browser]
    end

    subgraph "AWS Cloud"
        subgraph "Edge Layer"
            ALB[Application Load Balancer]
        end

        subgraph "EKS Cluster"
            subgraph "Frontend Tier"
                Frontend[React Frontend<br/>Nginx:80]
            end

            subgraph "Application Tier"
                UserSvc[User Service<br/>:3001]
                ProductSvc[Product Service<br/>:3002]
                OrderSvc[Order Service<br/>:3003]
                PaymentSvc[Payment Service<br/>:3004]
            end

            subgraph "Data Tier"
                MongoDB[(MongoDB<br/>27017)]
                Redis[(Redis<br/>6379)]
            end

            subgraph "Observability"
                Prometheus[Prometheus<br/>Metrics]
                Grafana[Grafana<br/>Dashboards]
                Loki[Loki<br/>Logs]
            end
        end

        subgraph "AWS Services"
            ECR[ECR<br/>Container Registry]
            Secrets[Secrets Manager]
            EBS[EBS Volumes]
        end
    end

    User --> Browser
    Browser --> ALB
    ALB --> Frontend
    Frontend --> UserSvc
    Frontend --> ProductSvc
    Frontend --> OrderSvc
    Frontend --> PaymentSvc
    
    UserSvc --> MongoDB
    ProductSvc --> MongoDB
    OrderSvc --> MongoDB
    PaymentSvc --> MongoDB
    
    UserSvc --> Redis
    
    UserSvc -.-> Prometheus
    ProductSvc -.-> Prometheus
    OrderSvc -.-> Prometheus
    PaymentSvc -.-> Prometheus
    
    Prometheus --> Grafana
    Frontend -.-> Loki
    UserSvc -.-> Loki
    ProductSvc -.-> Loki
    OrderSvc -.-> Loki
    PaymentSvc -.-> Loki
    
    ECR -.-> Frontend
    ECR -.-> UserSvc
    ECR -.-> ProductSvc
    ECR -.-> OrderSvc
    ECR -.-> PaymentSvc
    
    Secrets -.-> UserSvc
    Secrets -.-> ProductSvc
    Secrets -.-> OrderSvc
    Secrets -.-> PaymentSvc
    
    EBS -.-> MongoDB
    EBS -.-> Redis