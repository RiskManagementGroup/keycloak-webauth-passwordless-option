package dk.rmgroup.keycloak.authenticator;

import org.jboss.logging.Logger;
import org.keycloak.authentication.AuthenticationFlowContext;
import org.keycloak.authentication.authenticators.browser.UsernamePasswordForm;
import org.keycloak.authentication.authenticators.browser.WebAuthnPasswordlessAuthenticator;
import org.keycloak.forms.login.LoginFormsProvider;
import org.keycloak.models.KeycloakSession;
import org.keycloak.protocol.oidc.OIDCLoginProtocol;
import org.keycloak.services.managers.AuthenticationManager;
import org.keycloak.utils.StringUtil;

import jakarta.ws.rs.core.MultivaluedHashMap;
import jakarta.ws.rs.core.MultivaluedMap;
import jakarta.ws.rs.core.Response;

public class WebAuthnPasswordlessOptionAuthenticator extends WebAuthnPasswordlessAuthenticator {

  private static final Logger logger = Logger.getLogger(WebAuthnPasswordlessOptionAuthenticator.class);

  protected static final String USER_SET_BEFORE_USERNAME_PASSWORD_AUTH = "USER_SET_BEFORE_USERNAME_PASSWORD_AUTH";

  public WebAuthnPasswordlessOptionAuthenticator(KeycloakSession session) {
    super(session);
  }

  @Override
  public void authenticate(AuthenticationFlowContext context) {
    super.authenticate(context);

    MultivaluedMap<String, String> formData = new MultivaluedHashMap<>();
    String loginHint = context.getAuthenticationSession().getClientNote(OIDCLoginProtocol.LOGIN_HINT_PARAM);

    String rememberMeUsername = AuthenticationManager.getRememberMeUsername(context.getSession());

    if (context.getUser() != null) {
      LoginFormsProvider form = context.form();
      form.setAttribute(LoginFormsProvider.USERNAME_HIDDEN, true);
      form.setAttribute(LoginFormsProvider.REGISTRATION_DISABLED, true);
      context.getAuthenticationSession().setAuthNote(USER_SET_BEFORE_USERNAME_PASSWORD_AUTH, "true");
    } else {
      context.getAuthenticationSession().removeAuthNote(USER_SET_BEFORE_USERNAME_PASSWORD_AUTH);
      if (loginHint != null || rememberMeUsername != null) {
        if (loginHint != null) {
          formData.add(AuthenticationManager.FORM_USERNAME, loginHint);
        } else {
          formData.add(AuthenticationManager.FORM_USERNAME, rememberMeUsername);
          formData.add("rememberMe", "on");
        }
      }
    }

    Response challenge = context.form()
        .setFormData(formData)
        .createForm("webauthn-authenticate-passwordless-option.ftl");
    context.challenge(challenge);
  }

  @Override
  public void action(AuthenticationFlowContext context) {
    MultivaluedMap<String, String> formData = context.getHttpRequest().getDecodedFormParameters();
    if (formData.containsKey("cancel")) {
      context.cancelLogin();
      return;
    }

    String username = formData.getFirst(AuthenticationManager.FORM_USERNAME);
    if (StringUtil.isNotBlank(username)) {
      boolean result = new UsernamePasswordForm().validateUserAndPassword(context, formData);
      if (!result) {
        return;
      }
      context.success();
    } else {
      super.action(context);
    }
  }

  @Override
  public boolean requiresUser() {
    return false;
  }
}