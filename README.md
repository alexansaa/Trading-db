<a name="readme-top"></a>

# 📗 Table of Contents

- [📖 About the Project](#about-project)
  - [🛠 Built With](#built-with)
    - [Tech Stack](#tech-stack)
    - [Key Features](#key-features)
- [💻 Getting Started](#getting-started)
  - [Setup](#setup)
  - [Prerequisites](#prerequisites)
  - [Run](#run)
  - [Usage](#usage)
  - [Run tests](#run-tests)
  - [Deployment](#deployment)
  - [Schema](#schema)
  - [Migrations](#Migrations)
- [👥 Authors](#authors)
- [🔭 Future Features](#future-features)
- [🤝 Contributing](#contributing)
- [⭐️ Show your support](#support)
- [🙏 Acknowledgements](#acknowledgements)
- [📝 License](#license)

# 📖 Trading Database Layer <a name="about-project"></a>

**Trading Database Layer**
This project represents the SQL Layer of the Trading-App Stack, responsible for storing, structuring, and managing all persistent data used across the system.

It provides a unified data model for market prices, user sessions, trade configurations, and analytics results. This layer ensures data integrity, consistency, and availability to both the Java API layer and the Python analytics layer.

The database is containerized with Docker, and version-controlled through Flyway migrations, enabling reproducible environments for development, certification, and production deployments.

Other repos on the App Stack for this project:
- [Trading App Front-end](https://github.com/alexansaa/TradingAppFrontEnd)
- [Trading App Java Layer](https://github.com/alexansaa/TradingJavaLayer)
- [Trading App Python Layer](https://github.com/alexansaa/TradingPythonLayer)

## 🛠 Built With <a name="built-with"></a>

### Tech Stack <a name="tech-stack"></a>

<details>
  <summary>Core Technologies</summary>
  <ul>
    <li><a href="https://www.microsoft.com/en-us/sql-server">SQL Server</a></li>
    <li><a href="https://flywaydb.org/">Flyway</a></li>
    <li><a href="https://www.docker.com/">Docker</a></li>
    <li><a href="https://azure.microsoft.com/en-us/products/devops">Azure DevOps</a></li>
  </ul>
</details>

### Key Features <a name="key-features"></a>

- 🧱 **Centralized Schema** Provides a shared data foundation for all application layers.
- 💾 **Transactional Consistency** Ensures atomic, consistent, isolated, and durable (ACID) operations.
- 🚀 **Flyway Migration Control** Enables versioned and automated schema updates via DevOps pipelines.
- 🐳 **Containerized Deployment** Runs in Docker under the trading-core network for easy integration.
- 🔒 **Secure Connectivity** Uses environment-based credentials for controlled access across layers.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## 💻 Getting Started <a name="getting-started"></a>

To get a local copy up and running, follow these steps.

### Prerequisites

- Docker & Docker Compose
- SQL Server 2022+ or compatible image
- Flyway CLI (optional for manual migration testing)
- Git for repository cloning
- Proper environment configuration (.env or pipeline variables)

### Setup

Clone this repository to your desired folder:

```sh
  git clone https://github.com/alexansaa/Trading-db.git
  cd Trading-db
```
Create the shared Docker network (if not already existing):

```sh
  docker network create trading-core || true
```

### Run

Run the SQL Server container:

```sh
  docker compose up -d
```
Once started, the database will be available on:

```sh
  http://localhost:1433
```

### Schema

The main schema is market, containing the following core tables:

Table	Description
PriceBar	Stores time-series data for stock prices (symbol, date, open, high, low, close, volume).
Symbol	Lists tracked symbols and metadata.
Source	Records the data provider (e.g., Tiingo).
JobHistory	Logs data ingestion and update tasks.

### Migrations

Migrations are managed with Flyway and automatically executed via DevOps CI/CD or Docker entrypoint.

Run migrations manually:
```sh
  flyway migrate
```
<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- AUTHORS -->

## 👥 Authors <a name="authors"></a>

👤 **Alexander**

- GitHub: [https://github.com/alexansaa](https://github.com/alexansaa)
- LinkedIn: [https://www.linkedin.com/in/alexander-saavedra-garcia/](https://www.linkedin.com/in/alexander-saavedra-garcia/)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- FUTURE FEATURES -->

## 🔭 Future Features <a name="future-features"></a>

- [ ] 🗃️ **[Stored Procedures for Aggregated Metrics]** Precompute market indicators and summaries.
- [ ] 🔍 **[Indexing Optimization]** Enhance query performance for large datasets.
- [ ] 🧩 **[Database Partitioning]** Improve scalability for multi-symbol historical data.
- [ ] ☁️ **[Data Replication]** Enable cross-region database replication for high availability.
- [ ] 📈 **[ETL Pipelines]** Integrate external data ingestion directly from data providers.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTRIBUTING -->

## 🤝 Contributing <a name="contributing"></a>

Contributions, issues, and feature requests are welcome!

Feel free to check the [issues page](https://github.com/alexansaa/Trading-db/issues).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## ⭐️ Show your support <a name="support"></a>

If you like this project, please give it a star on GitHub

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## 🙏 Acknowledgments <a name="acknowledgements"></a>

I’d like to thank my wife for her patience and unwavering support during my darkest and most isolated days, when completing systems like these demanded every bit of my time, focus, and perseverance

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- LICENSE -->

## 📝 License <a name="license"></a>

This project is licensed under the [GNU](./LICENSE.md) General Public License.

<p align="right">(<a href="#readme-top">back to top</a>)</p>
