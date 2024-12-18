# quickstart-aws-containers
⚠️ This is very much in WIP phase. Though the code and workflows can be used to deploy to AWS⚠️

## Prerequisites

- BCGOV AWS account with appropriate permissions
- AWS CLI installed and configured (If interaction with AWS account is preferred)
- Docker/Podman installed (To run database and flyway migrations or whole stack)
- Node.js and npm installed (If not using docker compose for whole stack, to run backend and frontend)


# Folder Structure
```
/quickstart-aws-containers
├── .github/                   # GitHub workflows and actions
├── terraform/                 # Terragrunt configuration files
├── infrastructure/            # Terraform code for each component
│   ├── api/                   # API(ECS) related terraform code(backend)
│   ├── frontend/              # Cloudfront with WAF
│   ├── database/              # Aurora RDS database
├── backend/                   # Node Nest express backend API code
├── frontend/                  # Vite + React SPA
├── migrations/                # Flyway Migrations scripts to run database schema migrations
├── docker-compose.yml         # Docker compose file
├── README.md                  # Project documentation
└── package.json               # Node.js monorepo for eslint and prettier
```

- **.github/**: Contains GitHub workflows and actions for CI/CD.
- **terraform/**: Contains Terragrunt configuration files.
- **infrastructure/**: Contains Terraform code for each component.
    - **api/**: Contains Terraform code for the backend API (ECS).
    - **frontend/**: Contains Terraform code for Cloudfront with WAF.
    - **database/**: Contains Terraform code for Aurora RDS database.
- **backend/**: Contains Node Nest express backend API code.
- **frontend/**: Contains Vite + React SPA code.
- **docker-compose.yml**: Docker compose file for local development.
- **README.md**: Project documentation.
- **package.json**: Node.js monorepo configuration for eslint and prettier.

# Runnin Locally
## Running Locally with Docker Compose

To run the entire stack locally using the `docker-compose.yml` file in the root directory, follow these steps:

1. Ensure Docker (or Podman) is installed and running on your machine.
2. Navigate to the root directory of the project:
    ```sh
    cd /c:/projects/NRS/quickstart-aws-containers
    ```
3. Build and start the containers:
    ```sh
    docker-compose up --build
    ```
4. The backend API should now be running at `http://localhost:3001` and the frontend at `http://localhost:3000`.

To stop the containers, press `Ctrl+C` in the terminal where `docker-compose` is running, or run:
```sh
docker-compose down
```