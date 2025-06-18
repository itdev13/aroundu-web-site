# Route Management System

## Overview

This document explains how the route management system works in the AroundU application, including how to set up web routing for direct URL navigation.

## Components

1. **RouteService**: A service class that centralizes all routing functionality.
2. **AppRoutes**: A class that defines all route names and route configurations.

## How to Use

### Basic Navigation

To navigate to a route, use the `RouteService` instead of directly using `Get.toNamed`:

```dart
// Get the singleton instance
final routeService = RouteService();

// Navigate to a route
routeService.navigateTo(AppRoutes.dashboard);

// Navigate to a route with parameters
routeService.navigateTo(
  AppRoutes.otherProfile,
  parameters: {'userId': '123'},
);
```

### Adding New Routes

To add a new route to the application:

1. Add a route name constant to the `AppRoutes` class:

```dart
static const String newRoute = '/new-route';
```

2. Add a `GetPage` object to the `routes` list in the `AppRoutes` class:

```dart
GetPage(
  name: newRoute,
  page: () => NewRouteView(),
  transition: Transition.rightToLeftWithFade,
),
```

## Web Routing Setup

The application is already set up to use path-based URL strategy for web routing, which allows users to navigate directly to specific screens via URLs.

### How Web Routing Works

1. **Path URL Strategy**: The application uses `usePathUrlStrategy()` in `main.dart` to enable clean URLs without hash fragments.

2. **Route Parameters**: Routes can include parameters in the URL path using the `:paramName` syntax:

```dart
static const String otherProfile = '/otherProfile/:userId';
```

3. **Accessing Parameters**: In the page builder function, you can access these parameters:

```dart
GetPage(
  name: otherProfile,
  page: () {
    final userId = Get.parameters['userId'];
    return ProfileView(userId: userId);
  },
),
```

### Direct URL Navigation

Users can navigate directly to specific screens by entering URLs in the browser:

- Dashboard: `https://yourdomain.com/dashboard`
- User Profile: `https://yourdomain.com/otherProfile/123`
- Notifications: `https://yourdomain.com/notifications`

### Generating URLs for Sharing

To generate a URL that can be shared with others:

```dart
final routeService = RouteService();
final url = routeService.createUrlPath(
  AppRoutes.otherProfile,
  parameters: {'userId': '123'},
);
// Result: '/otherProfile/123'
```

## Best Practices

1. **Always use RouteService**: Instead of using `Get.toNamed()` directly, use the methods provided by `RouteService`.

2. **Define all routes in AppRoutes**: Keep all route definitions centralized in the `AppRoutes` class.

3. **Use named parameters**: When a route requires parameters, use named parameters in the URL path (e.g., `/profile/:userId`) rather than query parameters.

4. **Handle missing parameters**: Always check if required parameters are present and provide appropriate fallbacks.

## Troubleshooting

### 404 Errors on Web

If you're getting 404 errors when directly accessing URLs on a deployed web app, you need to configure your web server to redirect all requests to `index.html`. This is necessary because Flutter web apps are single-page applications.

#### For Firebase Hosting

Add this to your `firebase.json`:

```json
{
  "hosting": {
    "public": "build/web",
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

#### For Nginx

```
location / {
  try_files $uri $uri/ /index.html;
}
```

#### For Apache

Create a `.htaccess` file in your web root:

```
RewriteEngine On
RewriteBase /
RewriteRule ^index\.html$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.html [L]
```
