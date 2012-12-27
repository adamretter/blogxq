xquery version "1.0";

(:~
: XQuery Module implementation for the Akismet API - http://akismet.com/development/api/
:
: Can be used with either Akismet or the TypePad AntiSpam service
:
: @author Adam Retter <adam@exist-db.org>
: @date 2011-06-24T21:26:00+02:00
:)

module namespace akismet = "http://akismet.com/xquery/api";
import module namespace http = "http://expath.org/ns/http-client";

declare variable $akismet:HTTP-OK := 200;

declare variable $akismet:endpoint := "api.antispam.typepad.com"; (: for TypePad :)
(: declare variable $akismet:endpoint := "rest.akismet.com"; :) (: for Akismet :)
declare variable $akismet:comment-check-service := "1.1/comment-check"; 
declare variable $akismet:submit-spam-service := "1.1/submit-spam";
declare variable $akismet:submit-ham-service := "1.1/submit-ham";

(:~
:   Calls the Akismet comment check service
:
:   @param api-key Your Akismet API key
:   @param comment
:   <comment xmlns="http://akismet.com/xquery/api">
:       <blog> The front page or home URL of the instance making the request. For a blog or wiki this would be the front page. Note: Must be a full URI, including http://. </blog> (required)
:       <user_ip> IP address of the comment submitter. </user_ip> (required)
:       <user_agent> User agent string of the web browser submitting the comment - typically the HTTP_USER_AGENT cgi variable. Not to be confused with the user agent of your Akismet library. </user_agent> (required)
:       <referrer> The content of the HTTP_REFERER header should be sent here. </referrer> (note spelling)
:       <permalink> The permanent location of the entry the comment was submitted to. </permalink>
:       <comment_type> May be blank, comment, trackback, pingback, or a made up value like "registration". </comment_type>
:       <comment_author> Name submitted with the comment </comment_author>
:       <comment_author_email> Email address submitted with the comment </comment_author_email>
:       <comment_author_url> URL submitted with comment </comment_author_url>
:       <comment_content> The content that was submitted. </comment_content>       
:   </comment>
:
:   @return true() or false() indicating if the comment is spam or not
:)
declare function akismet:comment-check($api-key as xs:string, $comment as element(akismet:comment)) as xs:boolean? {

    let $http-request :=
        <http:request href="{akismet:_get-service-uri($api-key, $akismet:comment-check-service)}" method="post" http="1.0" override-media-type="text/plain">
            <http:header name="User-Agent" value="eXist-db/1.5 | Hermes/0.2"/>
            <http:body media-type="application/x-www-form-urlencoded">{ akismet:_params-xml-to-form-urlencoded($comment)}</http:body>
        </http:request>
    return
        
        let $http-result := http:send-request($http-request) return
            if(xs:integer($http-result[1]/http:response/@status) eq $akismet:HTTP-OK)then
                let $akismet-result := $http-result[2] return
                    $akismet-result eq "true"
            else
                fn:error(xs:QName("akismet:error"), fn:concat("Akismet service responded with http code: ", $http-result/http:response/@status))
};

(:~
:   Calls the Akismet submit spam service
:
:   @param api-key Your Akismet API key
:   @param spam-comment
:   <comment xmlns="http://akismet.com/xquery/api">
:       <blog> The front page or home URL of the instance making the request. For a blog or wiki this would be the front page. Note: Must be a full URI, including http://. </blog> (required)
:       <user_ip> IP address of the comment submitter. </user_ip> (required)
:       <user_agent> User agent string of the web browser submitting the comment - typically the HTTP_USER_AGENT cgi variable. Not to be confused with the user agent of your Akismet library. </user_agent> (required)
:       <referrer> The content of the HTTP_REFERER header should be sent here. </referrer> (note spelling)
:       <permalink> The permanent location of the entry the comment was submitted to. </permalink>
:       <comment_type> May be blank, comment, trackback, pingback, or a made up value like "registration". </comment_type>
:       <comment_author> Name submitted with the comment </comment_author>
:       <comment_author_email> Email address submitted with the comment </comment_author_email>
:       <comment_author_url> URL submitted with comment </comment_author_url>
:       <comment_content> The content that was submitted. </comment_content>       
:   </comment>
:
:   @return true() or false() indicating if the spam was submitted or not
:)
declare function akismet:submit-spam($api-key as xs:string, $spam-comment as element(akismet:comment)) as xs:boolean {
    let $http-request :=
        <http:request href="{akismet:_get-service-uri($api-key, $akismet:submit-spam-service)}" method="post" http="1.0" override-media-type="text/plain">
            <http:header name="User-Agent" value="eXist-db/1.5 | Hermes/0.2"/>
            <http:body media-type="application/x-www-form-urlencoded">{ akismet:_params-xml-to-form-urlencoded($spam-comment)}</http:body>
        </http:request>
    return
        
        let $http-result := http:send-request($http-request) return
            xs:integer($http-result[1]/http:response/@status) eq $akismet:HTTP-OK
};

(:~
:   Calls the Akismet submit ham service
:
:   @param api-key Your Akismet API key
:   @param spam-comment
:   <comment xmlns="http://akismet.com/xquery/api">
:       <blog> The front page or home URL of the instance making the request. For a blog or wiki this would be the front page. Note: Must be a full URI, including http://. </blog> (required)
:       <user_ip> IP address of the comment submitter. </user_ip> (required)
:       <user_agent> User agent string of the web browser submitting the comment - typically the HTTP_USER_AGENT cgi variable. Not to be confused with the user agent of your Akismet library. </user_agent> (required)
:       <referrer> The content of the HTTP_REFERER header should be sent here. </referrer> (note spelling)
:       <permalink> The permanent location of the entry the comment was submitted to. </permalink>
:       <comment_type> May be blank, comment, trackback, pingback, or a made up value like "registration". </comment_type>
:       <comment_author> Name submitted with the comment </comment_author>
:       <comment_author_email> Email address submitted with the comment </comment_author_email>
:       <comment_author_url> URL submitted with comment </comment_author_url>
:       <comment_content> The content that was submitted. </comment_content>       
:   </comment>
:
:   @return true() or false() indicating if the spam was submitted or not
:)
declare function akismet:submit-ham($api-key as xs:string, $ham-comment as element(akismet:comment)) as xs:boolean {
    let $http-request :=
        <http:request href="{akismet:_get-service-uri($api-key, $akismet:submit-spam-service)}" method="post" http="1.0" override-media-type="text/plain">
            <http:header name="User-Agent" value="eXist-db/1.5 | Hermes/0.2"/>
            <http:body media-type="application/x-www-form-urlencoded">{ akismet:_params-xml-to-form-urlencoded($ham-comment)}</http:body>
        </http:request>
    return
        
        let $http-result := http:send-request($http-request) return
            xs:integer($http-result[1]/http:response/@status) eq $akismet:HTTP-OK
};

declare function akismet:_get-service-uri($api-key as xs:string, $service as xs:string) as xs:string {
    fn:concat("http://", $api-key, ".", $akismet:endpoint, "/", $service)
};

declare function akismet:_params-xml-to-form-urlencoded($params as element()) as xs:string {
    fn:string-join(
        for $param in $params/child::element() return
            fn:concat(fn:local-name($param), "=", fn:encode-for-uri($param/text()))
        ,
        "&amp;"
    )
};