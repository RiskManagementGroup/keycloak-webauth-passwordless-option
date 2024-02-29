<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=false; section>
    <#if section = "title">
    <#elseif section = "header">
    <#elseif section = "form">
        <form id="kc-confirm-form" class="${properties.kcFormClass!}" action="${url.loginAction}" method="post">
            <div class="col-xs-12 col-sm-12 col-md-12 col-lg-12">
                <h2 style="margin-top:0px;text-align: center;">${msg("enableWebAuthnTitle")}</h2>
                <p class="lead">${msg("enableWebAuthnMessage")}</p>
            </div>
            <div class="${properties.kcFormButtonsClass!}">
                <button
                    class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!} ${properties.kcButtonLargeClass!}"
                    name="user-confirm-answer"
                    type="submit"
                    style="background-color: #04AA6D;"
                    value="yes">
                    ${msg("enableWebAuthnButtonText")}
                </button>
               <button
                    class="${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!} ${properties.kcButtonLargeClass!}"
                    style="margin-top: 10px"
                    name="user-confirm-answer"
                    type="submit"
                    value="no">
                    ${msg("doCancel")}
                </button>
            </div>
        </form>
    </#if>
</@layout.registrationLayout>