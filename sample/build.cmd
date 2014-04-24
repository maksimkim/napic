@echo off

rem *** path to tools ***
set java="c:\Program Files (x86)\Java\jre7\bin\java.exe"
set saxon_package=tools\saxon\saxon9.jar
set xsl=..\xsl

rem *** generation variables ***
set out_path=dist
set out_path_contracts=%out_path%\Napic.Sample.Contracts
set out_path_client=%out_path%\Napic.Sample.Client
set out_ns_contracts=Napic.Sample.Contracts
set out_ns_client=Napic.Sample.Client
set type_map_path=.\typeMap.xml


set saxon= %java% -jar %saxon_package%
@rd /S /Q %out_path%
cd "%~dp0"

echo Generating representation

@mkdir %out_path_contracts%
set full_type_map_path=%cd%\%type_map_path%
set type_map_uri=file:///%full_type_map_path:\=/%
%saxon% -xi:on -o:%out_path_contracts%\nil.cs -xsl:%xsl%\cscontracts.xsl -s:src\schemas\mapi.xsd ns="%out_ns_contracts%" typeMapPath="%type_map_uri%"

rem echo Generating client
rem @mkdir %out_path_client%
rem %saxon% -xi:on -o:"%out_path_client%\nil.cs -xsl:%xsl%\csclient.xsl -s:src\mapi.wadl apiname="ApiManagement" ns="%out_ns_client%" nss="System.Xml.Linq,Microsoft.WindowsAzure.ApiManagement.Framework.WebApi.Client,Microsoft.WindowsAzure.ApiManagement.Contracts" representationNs="urn:microsoft:windowsazure:apimanagement:mgmt"



echo Done