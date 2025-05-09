package dk.rmgroup.keycloak.authenticator;

import org.jboss.logging.Logger;
import org.keycloak.authentication.AuthenticationFlowContext;
import org.keycloak.authentication.Authenticator;
import org.keycloak.forms.login.freemarker.model.WebAuthnAuthenticatorsBean;
import org.keycloak.models.KeycloakSession;
import org.keycloak.models.RealmModel;
import org.keycloak.models.UserModel;
import org.keycloak.sessions.AuthenticationSessionModel;

import jakarta.ws.rs.core.MultivaluedMap;
import jakarta.ws.rs.core.Response;

public class WebAuthnConditionalEnrollmentAuthenticator implements Authenticator {
  private static final Logger LOG = Logger.getLogger(WebAuthnConditionalEnrollmentAuthenticator.class);

  private static final String TEMPLATE_NAME = "webauthn-conditional-enrollment.ftl";

  private static final String FORM_PARAM_USER_CONFIRM_ANSWER = "user-confirm-answer";

  @Override
  public void authenticate(AuthenticationFlowContext context) {
    if (userHasWebAuthnAuthenticator(context)) {
      LOG.debugf("User already registered webauthn authenticator", new Object[0]);
      context.success();
      return;
    }
    Response challenge = context.form().createForm(TEMPLATE_NAME);
    context.challenge(challenge);
  }

  private Boolean userHasWebAuthnAuthenticator(AuthenticationFlowContext context) {
    UserModel user = context.getUser();
    if (user != null) {
      LOG.debugf("Looking for webauthn-passworless authenticator...", new Object[0]);
      WebAuthnAuthenticatorsBean authenticators = new WebAuthnAuthenticatorsBean(context.getSession(),
          context.getRealm(), user, "webauthn-passwordless");
      if (authenticators.getAuthenticators().isEmpty()) {
        LOG.debugf("Looking for webauthn authenticator...", new Object[0]);
        authenticators = new WebAuthnAuthenticatorsBean(context.getSession(), context.getRealm(), user, "webauthn");
      }
      return !authenticators.getAuthenticators().isEmpty();
    }
    return false;
  }

  @Override
  public void action(AuthenticationFlowContext context) {
    MultivaluedMap<String, String> formData = context.getHttpRequest().getDecodedFormParameters();
    String answer = (String) formData.getFirst(FORM_PARAM_USER_CONFIRM_ANSWER);
    LOG.debugf("Username answer is: %s", answer);
    if ("yes".equalsIgnoreCase(answer)) {
      AuthenticationSessionModel authenticationSession = context.getAuthenticationSession();
      if (!authenticationSession.getRequiredActions().contains("webauthn-register-passwordless"))
        authenticationSession.addRequiredAction("webauthn-register-passwordless");

    }
    context.success();
  }

  @Override
  public boolean requiresUser() {
    return false;
  }

  @Override
  public boolean configuredFor(KeycloakSession keycloakSession, RealmModel realmModel, UserModel userModel) {
    return true;
  }

  @Override
  public void setRequiredActions(KeycloakSession keycloakSession, RealmModel realmModel, UserModel userModel) {
  }

  @Override
  public void close() {
  }
}