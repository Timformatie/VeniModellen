# VeniModellen

A personalized decision support tool for achieving personal meaningful goals in hand therapy treatment, developed for Erasmus MC/Xpert Clinics.

## Overview

VeniModellen is an R Shiny application that provides a **Personalized Decision Model for Achieving Personal Goals (Personal Meaningful Gain)**. The model was developed by [Robbert Wouters](https://www.erasmusmc.nl/en/research/researchers/wouters-robbert). The tool visualizes treatment outcome predictions using interactive Sankey diagrams, helping healthcare professionals and patients make informed decisions about treatment options for hand conditions.

The application is displayed via iframe in another [dashboard](https://github.com/equipezorgbedrijven/r-artsendashboard) called "r-artsendashboard", owned by Equipe Clinics. The idea is that healthcare professionals first select a patient in their survey platform (called "Pulse"), which then opens the "r-artsendashboard" dashboard pre-filled with the selected patient data. The "r-artsendashboard" dashboard contains a tab (note: this tab is shown only to selected healthcare professionals) that displays the iframe with the "VeniModellen" application. This application is also pre-filled with the selected patient data, which is passed by and then extracted from the iframe URL parameters (to fill the dashboard inputs).

### Key Features

- **Interactive Sankey visualizations**: Shows treatment pathways and outcome probabilities
- **Insight into three treatment options**: 
  - Hand therapy (Handtherapie)
  - Injection therapy (Injectie)
  - Surgical treatment (Operatie)
- **Personalized predictions**: Based on individual patient characteristics
- **Responsive design**: Modern, user-friendly interface
- **Real-time updates**: Dynamic visualizations based on user input
- **Multi-language support**: Available in Dutch (NL) and English (EN)

## Model Background

The prediction model was fully developed by Robbert Wouters, is based on data from **5,010 patients** and provides outcome predictions at **3 months post-treatment**. The model uses various patient characteristics to predict the likelihood of achieving personal meaningful goals with different treatment approaches.

### Patient Input Parameters

- **Demographics**: Age, weight, height
- **Clinical characteristics**:
  - Diagnosis
  - Primary goal
  - Baseline score for primary goal
  - Goal score for primary goal
  - Symptom duration (months)
  - NRS pain during loading score
  - NRS function score
  - IPQ Concern score
  - IPQ Emotional Response score
- **Treatment preferences**: Selection of treatment modalities to compare

All input parameters are prefilled based on the selected patient in the "Pulse" survey platform, via the "r-artsendashboard" dashboard. But users can also manually adjust these parameters within the application.

**The model returns** probabilities of achieving the personal meaningful goal for each treatment option, which are visualized in the Sankey diagrams.

### Compliance with AI Act

There are certain requirements for AI based-tools because of the AI Act. currently there is no mention included in the dashboard that the Sankey diagrams results are based on a Machine Learning model. Also there is not yet an option for users to file a complaint or provide feedback about the AI system. Consider adding both these elements to the application.
    - 27-10-2025: discussed points about adding these elements with Robbert Wouters. Currently the tool is in the pilot phase, so we will wait with implementing these elements until the tool is more widely used.

## Technology Stack

- **Framework**: R Shiny with Golem architecture
- **Visualization**: Highcharter, NetworkD3 for Sankey diagrams
- **UI Components**: bslib, bs4Dash for modern Bootstrap interface
- **Machine Learning**: gbm (Gradient Boosting Machine), caret for model predictions
- **Internationalization**: shiny.i18n for multi-language support
- **Data Processing**: data.table, dplyr for efficient data manipulation

Note: because the tool is embedded in another dashboard via iframe, there is **no authentication** (e.g. Auth0) implemented in this application itself.

## Installation & Setup

### Prerequisites

- R (>= 4.0)
- Docker (optional, for containerized deployment)

### Local Development

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Timformatie/VeniModellen.git
   cd VeniModellen
   ```

2. **Install dependencies**:
   ```r
   # Install renv for dependency management
   install.packages("renv")
   
   # Restore project dependencies
   renv::restore()
   ```

3. **Run the application**:

    Use the app.R script to launch the app locally:

   ```r
    pkgload::load_all()
    options( "golem.app.prod" = FALSE, "golem.pkg.name" = "VeniModellen")
    options(shiny.port = 8080)
    run_app()
   ```

   Or use the script in `dev/run_dev.R`.

   The application will be available at `http://localhost:8080`

## Project Structure

```
VeniModellen/
├── app.R                      # Main application entry point
├── DESCRIPTION               # Package metadata
├── NAMESPACE                 # Package namespace
├── VeniModellen.Rproj        # RStudio project file
├── docker-compose.yml       # Multi-container setup
├── Dockerfile               # Container configuration
├── renv.lock                # Dependency lock file
├── R/                        # R source code
│   ├── app_config.R         # Application configuration
│   ├── app_server.R         # Server logic
│   ├── app_ui.R             # User interface definition
│   ├── run_app.R            # Main application runner
│   ├── fct_create_modal.R   # Modal dialog functions
│   ├── fct_create_plot_datatable.R  # Plot and datatable functions
│   ├── fct_create_sankey.R  # Sankey plot creation
│   ├── fct_fct_slider_layout.R      # Slider layout functions
│   ├── fct_recode_question.R        # Question recoding functions
│   ├── fct_transform_goal_to_english.R  # Translation functions
│   └── sysdata.rda          # System data
├── data/                     # Model data and datasets
│   ├── dt_sankey_*.rda      # Sankey diagram datasets (1-5)
│   ├── dt_train.rda         # Training dataset
│   ├── model.rda            # Main prediction model
│   ├── from_*.rda           # Source flow data (injection/operatie/therapie, nl/en)
│   └── to_*.rda             # Destination flow data (injection/operatie/therapie, nl/en)
├── data-raw/                 # Raw data processing scripts
│   └── Internal objects.R   # Internal object creation
├── dev/                      # Development scripts
│   ├── 01_start.R           # Initial project setup
│   ├── 02_dev.R             # Development workflow
│   ├── 03_deploy.R          # Deployment configuration
│   └── run_dev.R            # Development server
├── inst/                     # Installed files
│   ├── golem-config.yml     # Golem configuration
│   ├── service.yml          # Service configuration
│   ├── shiny-server.conf    # Shiny server configuration
│   ├── app/www/             # Static web assets
│   │   ├── custom.css       # Custom styling
│   │   ├── favicon.png      # Application icon
│   │   ├── flag_*.png       # Language flags
│   │   ├── happy-smiley.webp # Success icon
│   │   ├── sad-smiley.png   # Failure icon
│   │   └── t1.png           # Additional graphics
│   └── extdata/             # External data files
│       ├── continue_surgery.xlsx    # Surgery continuation data
│       ├── features gbm.xlsx       # Model input features data
│       ├── model_train_*.RData     # Pre-trained GBM model
│       └── translation.json       # Multi-language translations
├── man/                      # Documentation
│   ├── recode_primary_goal.Rd      # Function documentation
│   └── run_app.Rd                  # App runner documentation
├── renv/                     # R environment management
│   ├── activate.R           # renv activation script
│   ├── settings.json        # renv settings
│   └── staging/             # renv staging area
└── tests/                    # Unit tests
    ├── testthat.R           # Test configuration
    └── testthat/            # Test files
        └── test-fct_helpers.R  # Helper function tests
```

## Usage

1. **Select treatment options**: Choose which treatments to include in the comparison
2. **Enter patient characteristics**: Fill in the required patient parameters (when available, these are prefilled based on the selected patient in the "Pulse" survey platform). Can be adjusted manually.
3. **View predictions**: Interactive Sankey diagrams show:
   - Treatment pathways
   - Success probabilities
   - Alternative treatment routes
4. **Language toggle**: Switch between Dutch and English interface

## Development

### Golem Framework

This application is built using the [Golem](https://thinkr-open.github.io/golem/) framework.

### Key Development Scripts

- `dev/01_start.R`: Initial project setup
- `dev/02_dev.R`: Development workflow
- `dev/03_deploy.R`: Deployment configuration
- `dev/run_dev.R`: Development server

### Adding New Features

1. Create new modules or functions in the `R/` directory with the code in `dev/02_dev.R`
2. Add tests in `tests/testthat/`, note/todo: currently no tests are implemented
3. Update documentation using `devtools::document()`
4. Test locally with the script `dev/run_dev.R` or `app.R`

### Data & Models

The application include a pre-trained machine learning model and other internal data/objects used in the dashboard:

- **Model file(s)**: Located in `inst/extdata/`. The model currently used is "model_train_gbm_after_rfe_20240311".
- **Internal data**: Created in `R/data-raw/Internal objects.R` and saved as `.RData` files. This includes for example the model used to make predictions or a list of colors used in the dashboard.
- **External data**: Stored in `inst/extdata/`. This includes:
    - "continue_surgery.xlsx": Data on patients who continued to surgery after hand therapy or injection therapy. This data is used to inform the Sankey diagrams about possible treatment pathways.
    - "features gbm.xlsx": Information about the features used in the GBM model.
    - translation.json: Contains the translations for multi-language support.

### Adding new users
The "r-artsendashboard" dashboard contains a tab that displays the iframe with the "VeniModellen" application. This tab is shown only to a list of selected healthcare professionals. To add a new user to this list:
1. The current list of users can be found in [Google Cloud secret manager](https://console.cloud.google.com/security/secret-manager/secret/r_artsendashboard_env_vars/versions?project=equipe-337111). Add the new user's details there.
2. Update the list of users in the Github secret of [the "r-artsendashboard" repository](https://github.com/equipezorgbedrijven/r-artsendashboard).
3. When releasing a new version of the "r-artsendashboard" dashboard, the updated list of users is pulled from the Github secret during the deployment process. See `release.yml`: "Create and populate env_vars file".

## License

This project is developed by Timformatie. Please contact the authors for licensing information.

## Support

For technical support or questions about the application, please contact:
- Email: [support@timformatie.nl](mailto:support@timformatie.nl)
- Organization: Timformatie

---