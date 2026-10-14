# SIGMA-251 — IoT Environmental Monitoring System for Agriculture

SIGMA-251 is an Internet of Things (IoT) environmental monitoring system developed as an undergraduate degree project. Its purpose is to collect, process, store, and visualize environmental data relevant to agricultural crop monitoring.

The system integrates environmental sensors, a field acquisition node, wireless communication, a web application, and cloud-based data storage. Its architecture supports operation during Internet connectivity interruptions by retaining data locally and synchronizing pending information when connectivity is restored.

## Table of Contents

- [Key Features](#key-features)
- [System Architecture](#system-architecture)
- [Hardware Components](#hardware-components)
- [Software Technologies](#software-technologies)
- [How It Works](#how-it-works)
- [Offline Operation and Data Synchronization](#offline-operation-and-data-synchronization)
- [Web Application](#web-application)
- [Deployment](#deployment)
- [Local Installation and Setup](#local-installation-and-setup)
- [Hardware Requirements](#hardware-requirements)
- [Documentation](#documentation)
- [Project Status](#project-status)

## Key Features

- **Environmental monitoring:** collects measurements related to agricultural growing conditions.
- **Sensor integration:** acquires data from digital and analog sensors.
- **Wireless communication:** transmits measurements using XBee modules.
- **Web-based visualization:** provides access to environmental measurements through a web browser.
- **Data storage:** retains measurements for later consultation and analysis.
- **Offline-first operation:** supports data retention during Internet connectivity interruptions.
- **Cloud synchronization:** synchronizes pending data when connectivity is restored.
- **Modular architecture:** separates data acquisition, reception, API services, database storage, and the web interface.

## System Architecture

SIGMA-251 consists of a field acquisition node, a receiving station, a backend API, a cloud database, and a web-based frontend.

The system follows this general data flow:

1. Environmental sensors collect measurements in the agricultural field.
2. The Waspmote node acquires and processes sensor signals.
3. XBee modules transmit the measurements wirelessly to a receiving station.
4. A Python receiver running on a computer processes the incoming data.
5. The system retains data locally and synchronizes it with the cloud when connectivity is available.
6. The backend API and PostgreSQL database support data management and persistence.
7. The web application provides access to the available measurements.

## Hardware Components

### Data Acquisition Node

The field node uses a **Libelium Waspmote Pro v1.2** equipped with an **Agriculture Sensor Board v2.0**. This configuration enables the integration of the environmental sensors used by the system.

### Environmental Sensors

| Sensor | Measured Variable | Unit |
|---|---|---|
| SHT75 | Air temperature | °C |
| SHT75 | Relative humidity | %RH |
| Watermark | Soil water tension | cbar |
| SR11-TR | Solar irradiance | W/m² |

Measurements are processed according to each sensor's electrical characteristics and the conversion equations implemented in the acquisition node.

### Wireless Communication

XBee modules provide wireless communication between the field node and the receiving station. The communication link uses IEEE 802.15.4 at 2.4 GHz.

The receiving module connects to a computer through a USB-to-serial adapter.

## Software Technologies

| Technology | Purpose |
|---|---|
| Python | Data reception and processing at the base station |
| FastAPI | Backend API development |
| React | Web interface development |
| Vite | Frontend development and build tooling |
| PostgreSQL | Relational database management |
| Supabase | Cloud database services |
| Vercel | Frontend deployment |
| Render | Backend deployment |
| Git and GitHub | Version control and source code hosting |

## How It Works

SIGMA-251 operates through the following stages:

1. **Data acquisition:** the sensors measure environmental variables, and the Waspmote node processes their signals.
2. **Wireless transmission:** the measurements are transmitted through the XBee communication modules.
3. **Data reception:** a computer receives the data through the connected XBee receiver.
4. **Data processing:** the Python receiver interprets the incoming measurements.
5. **Data storage:** the system retains data through its local and cloud storage mechanisms.
6. **Visualization:** the web application allows users to consult measurements and observe environmental variables.
7. **Synchronization:** when Internet connectivity is restored, pending data can be synchronized with the cloud database.

## Offline Operation and Data Synchronization

One of the main features of SIGMA-251 is its ability to handle Internet connectivity interruptions.

When Internet access is unavailable, the system can retain data using its local storage mechanisms. Once connectivity is restored, pending information can be synchronized with the cloud database according to the implemented synchronization workflow.

This approach helps reduce data loss and supports continuous monitoring in agricultural environments where Internet access may be limited or intermittent.

Local data retention and cloud synchronization are distinct processes. The availability of locally stored measurements does not necessarily imply that those measurements have already been uploaded to the cloud.

## Web Application

The web application provides access to the system's environmental data through a browser, without requiring users to interact directly with the database.

**Live application:**  
https://sigma-251.vercel.app/

The application is designed to support:

- Access to environmental measurements.
- Visualization of sensor data.
- Access from different devices using a compatible web browser.
- Consultation of available data according to connectivity and synchronization status.

## Deployment

SIGMA-251 uses separate services for the frontend and backend.

### Frontend

The frontend is developed with React and Vite and deployed on Vercel.

URL: https://sigma-251.vercel.app/

### Backend

The backend is developed with FastAPI and organized within the `sigma_api/` directory. It provides API services for communication between the application and the data infrastructure.

URL: https://sigma-251.onrender.com

### Database

The system uses PostgreSQL through Supabase for persistent cloud data storage.

Database access must follow the authentication and authorization mechanisms configured for the application. Private credentials and secret keys must never be committed to the repository.

## Local Installation and Setup

Running the complete system locally requires the source code, the dependencies for each component, and the appropriate environment configuration.

### General Requirements

- Git.
- Python and the dependencies required by the backend and data receiver.
- Node.js and npm for the frontend.
- The required Supabase configuration.
- XBee communication hardware and the Waspmote node for real sensor acquisition.

The exact dependency versions should be taken from the configuration files included in the repository.

### 1. Clone the Repository

```bash
git clone https://github.com/scsantosdth/SIGMA-251.git
cd SIGMA-251
```

### 2. Configure the Backend

The backend is located in the `sigma_api/` directory.

Install the dependencies specified by the project and configure the environment variables required for database connectivity and other services.

Do not include production credentials in the source code or commit files containing secrets.

The appropriate startup command should be verified against the backend's configuration files and deployment instructions.

### 3. Configure the Frontend

The frontend uses React and Vite.

Install the dependencies defined in `package.json` and configure the API URL for the intended environment.

Use the scripts defined in the frontend's `package.json` to start the development server or build the application.

### 4. Run the Data Receiver

The base-station receiver is implemented in Python and uses the `receiver.py` file.

To receive measurements from the physical node:

1. Connect the XBee receiver to the computer through a compatible USB-to-serial adapter.
2. Identify the appropriate serial port.
3. Configure the serial port and communication parameters required by the receiver.
4. Start the receiver using the execution procedure defined by the project.

The serial port and communication settings must be verified against the receiver's configuration and the connected hardware.

### 5. Verify the System

After configuring the components:

1. Verify communication between the Waspmote node and the XBee receiver.
2. Confirm that the receiver correctly processes incoming measurements.
3. Check local data storage.
4. Verify communication between the backend and the database.
5. Open the web application and confirm that the available measurements are displayed.
6. Test the system without Internet access and verify synchronization after connectivity is restored.

> **Note:** The steps above describe the general setup procedure. Exact installation commands, environment variable names, and serial communication parameters must be confirmed from the actual source code and configuration files.

## Hardware Requirements

The complete system requires the following hardware:

- Libelium Waspmote Pro v1.2.
- Agriculture Sensor Board v2.0.
- SHT75, Watermark, and SR11-TR sensors.
- XBee modules compatible with the project's communication configuration.
- A compatible USB-to-serial adapter for the receiving XBee module.
- A computer to run the data receiver.
- Suitable power supplies and mounting components for field testing.

Running or accessing the web application alone does not require the complete sensor hardware, provided the required backend services and data are available.

## Documentation

SIGMA-251 is an academic degree project that includes the source code for the implemented system components.

For additional information about the system design, hardware installation, configuration, and validation results, consult the project's final report and installation and user manual included in the academic project documentation.

## Project Status

SIGMA-251 integrates environmental data acquisition, wireless communication, data processing, storage, and web-based visualization.

The system has been evaluated through tests in agricultural environments, including operation under different connectivity conditions. Its architecture provides a foundation for further development of IoT-based environmental monitoring solutions for the agricultural sector.

## Project Links

- **Source code:** https://github.com/scsantosdth/SIGMA-251
- **Web application:** https://sigma-251.vercel.app/
- **Backend API:** https://sigma-251.onrender.com
