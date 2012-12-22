xquery version "1.0";

declare namespace request = "http://exist-db.org/xquery/request";
declare namespace transform = "http://exist-db.org/xquery/transform";
declare namespace util = "http://exist-db.org/xquery/util";

let $original-uri := concat(request:get-header("Host"), request:get-header("nginx-request-uri")) return
(:, $null := util:log("debug", concat("ADAM LOOK HERE=", $original-uri)) return :)

let $uri := request:get-uri() return

    if(starts-with($uri, "/db/adamretter.org.uk/blog/entries/") and ends-with($uri, ".xml"))then
    (
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="/db/adamretter.org.uk/blog.xql">
                <add-parameter name="entry" value="{request:get-uri()}"/>
                {
                    for $param-name in request:get-parameter-names() return
                        if($param-name ne "entry")then(
                            for $param-value in request:get-parameter($param-name, ()) return
                                <add-parameter name="{$param-name}" value="{$param-value}"/>
                        )else()
                }
            </forward>
        </dispatch>
    )
    else()