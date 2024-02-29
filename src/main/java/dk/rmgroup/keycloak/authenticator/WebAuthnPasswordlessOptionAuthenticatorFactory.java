package dk.rmgroup.keycloak.authenticator;

import org.keycloak.authentication.Authenticator;
import org.keycloak.authentication.authenticators.browser.WebAuthnAuthenticatorFactory;
import org.keycloak.models.KeycloakSession;
import org.keycloak.models.credential.WebAuthnCredentialModel;

public class WebAuthnPasswordlessOptionAuthenticatorFactory extends WebAuthnAuthenticatorFactory {

  public static final String PROVIDER_ID = "webauthn-passwordless-option";

  @Override
  public String getReferenceCategory() {
    return WebAuthnCredentialModel.TYPE_PASSWORDLESS;
  }

  @Override
  public String getDisplayType() {
    return "WebAuthn Passwordless Option Authenticator";
  }

  @Override
  public String getHelpText() {
    return "Authenticator for Passwordless WebAuthn authentication with option for username and password";
  }

  @Override
  public Authenticator create(KeycloakSession session) {
    return new WebAuthnPasswordlessOptionAuthenticator(session);
  }

  @Override
  public String getId() {
    return PROVIDER_ID;
  }

  @Override
  public boolean isUserSetupAllowed() {
    return false;
  }
}