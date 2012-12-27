xquery version "1.0";

declare variable $exist:root external;
declare variable $exist:prefix external;
declare variable $exist:controller external;
declare variable $exist:path external;
declare variable $exist:resource external;

if ($exist:path eq '') then
    (: work around trailing slash bug :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="{concat(request:get-uri(), '/')}"/>
    </dispatch>
else if ($exist:path eq "/") then
    (: redirect root path to blog.xql :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="blog.xql"/>
    </dispatch>
else if ($exist:path eq "/blog.xql") then
    (: forward to blog.xql's actual location in modules :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="modules/blog.xql"/>
    </dispatch>
else if (ends-with($exist:resource, '.xml')) then
    (: forward to blog.xql's location in modules :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/modules/blog.xql">
            <add-parameter name="entry" value="{$exist:path}"/>
        </forward>
    </dispatch>
else
    (: everything else is passed through :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>