xquery version "1.0";

(:~
: XQuery Module implementation for the Asirra API - http://research.microsoft.com/en-us/um/redmond/projects/asirra/
:
: @author Adam Retter <adam@exist-db.org>
: @date 2011-06-24T21:26:00+02:00
:)

module namespace asirra = "http://asirra.com/xquery/api";

import module namespace http = "http://expath.org/ns/http-client";

declare variable $asirra:HTTP-OK := 200;
declare variable $asirra:validation-endpoint := "http://challenge.asirra.com/cgi/Asirra?action=ValidateTicket&amp;ticket=";

(:~
: Validate an Asirra Ticket
:
: @param $asirra-ticket The Asirra ticket to validate
: 
: @return true() or false() indicating whether the ticket was valid
:)
declare function asirra:validate-ticket($asirra-ticket as xs:string) as xs:boolean {

    let $url := fn:concat($asirra:validation-endpoint, $asirra-ticket) return

        let $http-result := http:send-request(<http:request href="{$url}" method="get"/>) return
        
            if(xs:integer($http-result/http:response/@status) eq $asirra:HTTP-OK)then
                let $asirra-result := $http-result[2] return
                    $asirra-result/AsirraValidation/Result eq "Pass"
            else
                false()
};