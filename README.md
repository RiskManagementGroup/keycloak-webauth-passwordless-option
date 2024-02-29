# Keycloak WebAuthn Passwordless Login Option

Keycloak authentication step for adding the option to login with webauthn or username and password.

To make Keycloak recognize the authentication step the src/main/resources/META-INF folder and its content is required.

## Build

Requirements are Maven (verified 3.9.1) and Java (verified jdk 20.0.2).

To build a .jar file that can be used in Keycloak run the following command

```bash
mvn clean package
```

## Deploy

To deploy the authentication step in Keycloak copy the .jar file into the `/opt/keycloak/providers` folder.

When deploying to Docker, copy the file before running `kc.sh build` in the Docker file.
