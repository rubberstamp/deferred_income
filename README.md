# Deferred Income Management Application

## Overview

The Deferred Income Management Application is a Ruby on Rails web application designed to help users manage their deferred income effectively. The application allows users to import charges from Stripe, view monthly recurring revenue (MRR), and analyze their financial data through a user-friendly interface.

## Features

- **Charge Management**: Import charges from Stripe and manage them within the application.
- **Monthly Recurring Revenue (MRR)**: Calculate and display MRR based on recognition dates.
- **CSV Export**: Export charge data in CSV format for external analysis.
- **User Authentication**: Secure user accounts with authentication.
- **Responsive Design**: A modern UI built with Tailwind CSS for a better user experience.
- **Calendar View**: Visualize total deferred income in a calendar format.

## Technologies Used

- Ruby on Rails
- PostgreSQL (or your preferred database)
- Stripe API for payment processing
- Tailwind CSS for styling
- Rake for background tasks

## Getting Started

### Prerequisites

- Ruby (version 3.0 or higher)
- Rails (version 6.0 or higher)
- PostgreSQL (or any other database of your choice)
- Stripe account for payment processing

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/yourusername/deferred_income.git
   cd deferred_income