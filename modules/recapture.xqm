module namespace recap="http://www.exist-db.org/xquery/util/recapture";

declare namespace httpclient = "http://exist-db.org/xquery/httpclient";

declare variable $recap:VALIDATE_URI as xs:anyURI := xs:anyURI("http://api-verify.recaptcha.net/verify");

(:~
: Module for working with reCaptcha
:
: @author Adam Retter <adam.retter@exquery.org>
: @version 1.0
:)

declare function recap:validate($private-key as xs:string, $recaptcha-challenge as xs:string, $recaptcha-response as xs:string) as xs:boolean
{
    (: let $client-ip := request:get-remote-addr(), :)
    let $client-ip := request:get-header("X-Real-IP"),        (: if behind webserver proxy :)

     $post-fields := <httpclient:fields>
            <httpclient:field name="privatekey" value="{$private-key}"/>
            <httpclient:field name="remoteip" value="{$client-ip}"/>
            <httpclient:field name="challenge" value="{$recaptcha-challenge}"/>
            <httpclient:field name="response" value="{$recaptcha-response}"/>
        </httpclient:fields> return
    
        let $response := httpclient:post-form($recap:VALIDATE_URI, $post-fields, false(), ()) return
        
            let $recapture-response := $response/httpclient:body/text() return
                if(starts-with($recapture-response, "true"))then
                (
                    true()
                )
                else
                (
                    (: util:log("debug", concat("reCaptcha response='", $capture-response, "'")), :)    (: uncomment to debug reCaptcha response :)
                    false()
                )
};