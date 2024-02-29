<#import "template.ftl" as layout>
    <@layout.registrationLayout; section>
    <#if section = "title">
     title
    <#elseif section = "header">
        ${kcSanitize(msg("webauthn-login-title"))?no_esc}
    <#elseif section = "form">
        <form id="webauth" action="${url.loginAction}" method="post">
            <input type="hidden" id="clientDataJSON" name="clientDataJSON"/>
            <input type="hidden" id="authenticatorData" name="authenticatorData"/>
            <input type="hidden" id="signature" name="signature"/>
            <input type="hidden" id="credentialId" name="credentialId"/>
            <input type="hidden" id="userHandle" name="userHandle"/>
            <input type="hidden" id="error" name="error"/>
        </form>
        <div class="${properties.kcFormGroupClass!} no-bottom-margin">
            <div id="kc-form">
                <div id="kc-form-wrapper">
                    <#if realm.password>
                        <form id="kc-form-login" onsubmit="login.disabled = true; return true;" action="${url.loginAction}" method="post">
                            <#if !usernameHidden??>
                                <div class="${properties.kcFormGroupClass!}">
                                    <label for="username" class="${properties.kcLabelClass!}"><#if !realm.loginWithEmailAllowed>${msg("username")}<#elseif !realm.registrationEmailAsUsername>${msg("usernameOrEmail")}<#else>${msg("email")}</#if></label>

                                    <input tabindex="1" id="username" class="${properties.kcInputClass!}" name="username" value="${(login.username!'')}"  type="text" autofocus autocomplete="off"
                                        aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>"
                                    />

                                    <#if messagesPerField.existsError('username','password')>
                                        <span id="input-error" class="${properties.kcInputErrorMessageClass!}" aria-live="polite">
                                                ${kcSanitize(messagesPerField.getFirstError('username','password'))?no_esc}
                                        </span>
                                    </#if>

                                </div>
                            </#if>

                            <div class="${properties.kcFormGroupClass!}">
                                <label for="password" class="${properties.kcLabelClass!}">${msg("password")}</label>

                                <input tabindex="2" id="password" class="${properties.kcInputClass!}" name="password" type="password" autocomplete="off"
                                    aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>"
                                />

                                <#if usernameHidden?? && messagesPerField.existsError('username','password')>
                                    <span id="input-error" class="${properties.kcInputErrorMessageClass!}" aria-live="polite">
                                            ${kcSanitize(messagesPerField.getFirstError('username','password'))?no_esc}
                                    </span>
                                </#if>

                            </div>

                            <div class="${properties.kcFormGroupClass!} ${properties.kcFormSettingClass!}">
                                <div id="kc-form-options">
                                    <#if realm.rememberMe && !usernameHidden??>
                                        <div class="checkbox">
                                            <label>
                                                <#if login.rememberMe??>
                                                    <input tabindex="3" id="rememberMe" name="rememberMe" type="checkbox" checked> ${msg("rememberMe")}
                                                <#else>
                                                    <input tabindex="3" id="rememberMe" name="rememberMe" type="checkbox"> ${msg("rememberMe")}
                                                </#if>
                                            </label>
                                        </div>
                                    </#if>
                                    </div>
                                    <div class="${properties.kcFormOptionsWrapperClass!}">
                                        <#if realm.resetPasswordAllowed>
                                            <span><a tabindex="5" href="${url.loginResetCredentialsUrl}">${msg("doForgotPassword")}</a></span>
                                        </#if>
                                    </div>

                            </div>

                            <div id="kc-form-buttons" class="${properties.kcFormGroupClass!}">
                                <input type="hidden" id="id-hidden-input" name="credentialId" <#if auth.selectedCredential?has_content>value="${auth.selectedCredential}"</#if>/>
                                <input tabindex="4" class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!} ${properties.kcButtonLargeClass!}" name="login" id="kc-login" type="submit" value="${msg("doLogInWithPassword")}"/>
                            </div>
                        </form>
                    </#if>
                </div>
                <div id="kc-form-buttons-webauthn" >
                    <hr>
                    <input id="authenticateWebAuthnButton" type="button" onclick="webAuthnAuthenticate()" autofocus="autofocus"
                        value="${kcSanitize(msg("webauthn-doAuthenticate"))}"
                        class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!} ${properties.kcButtonLargeClass!}"/>
                </div>
            </div>
        </div>
    <script type="text/javascript" src="${url.resourcesCommonPath}/node_modules/jquery/dist/jquery.min.js"></script>
    <script type="text/javascript" src="${url.resourcesPath}/js/base64url.js"></script>
    <script type="text/javascript">
        const authnOptions = {
            challenge : "${challenge}",
            rpId : "${rpId}",
            createTimeout : ${createTimeout},
            isUserIdentified: ${isUserIdentified},
            userVerification: "${userVerification}"
        }

        window.onload = () => {
            if(!authnOptions.isUserIdentified) {
                document.getElementById("kc-form-login").style.display = "block";
            }
        }

        const getAllowCredentials = () => {
            let allowCredentials = [];
            let authn_use = document.forms['authn_select'].authn_use_chk;
            if (authn_use !== undefined) {                
                if (authn_use.length === undefined) {
                    allowCredentials.push({
                        id: base64url.decode(authn_use.value, {loose: true}),
                        type: 'public-key',
                    });
                } else {
                    for (let i = 0; i < authn_use.length; i++) {
                        allowCredentials.push({
                            id: base64url.decode(authn_use[i].value, {loose: true}),
                            type: 'public-key',
                        });
                    }
                }
            }
            return allowCredentials;
        }

        const getPublicKeyRequestOptions = () => {
            let publicKeyReqOptions = {};
            publicKeyReqOptions.rpId = authnOptions.rpId;
            publicKeyReqOptions.challenge = base64url.decode(authnOptions.challenge, { loose: true });
            publicKeyReqOptions.allowCredentials = !authnOptions.isUserIdentified ? [] : getAllowCredentials();

            if(authnOptions.createTimeout !== 0) publicKeyReqOptions.timeout = authnOptions.createTimeout * 1000;
            if (authnOptions.userVerification !== 'not specified') publicKeyReqOptions.userVerification = authnOptions.userVerification; 
            
            return publicKeyReqOptions;
        }

        const webAuthnAuthenticate = async (mediationOptions) => {
            
            const credential = await navigator.credentials.get({
                publicKey: getPublicKeyRequestOptions(),
                ...mediationOptions
            }).catch(handleWebAuthError);

            window.result = credential;

            $("#clientDataJSON").val(encodeBase64AsUint8Array(result.response.clientDataJSON));
            $("#authenticatorData").val(encodeBase64AsUint8Array(result.response.authenticatorData));
            $("#signature").val(encodeBase64AsUint8Array(result.response.signature));
            $("#credentialId").val(result.id);
            if(result.response.userHandle) {
                $("#userHandle").val(encodeBase64AsUint8Array(result.response.userHandle));
            }
            $("#webauth").submit();
        }

        const handleWebAuthError = (e) => {
            if (e.name !== 'NotAllowedError') {
                console.error(error);
            }
            $("#error").val(e);
            $("#webauth").submit();
        }

        const encodeBase64AsUint8Array = (value) => {
            return base64url.encode(new Uint8Array(value), { pad: false });
        }

    </script>
    <#elseif section = "info">

    </#if>
    </@layout.registrationLayout>