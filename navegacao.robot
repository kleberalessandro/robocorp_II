*** Settings ***
Documentation       Biblioteca responsável por toda navegação do menu lateral

*** Keywords ***
open the website
    [Documentation]    Abre o navegador maximizado.
    ...    Escolhi este método por ter melhor performance e pela necessidade
    ...    de carregar uma extensão que desabilita os alertas Js.
    [Arguments]    ${URL}    ${download_dir}=${None}
    ${prefs}    Create Dictionary    download.default_directory=${download_dir}
    ...    plugins.always_open_pdf_externally=${True}
    ${options}    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys
    Call Method    ${options}    add_experimental_option    prefs    ${prefs}
#    Call Method    ${options}    add_argument    start-maximized
#    Call Method    ${options}    add_argument    disable-web-security
#    Call Method    ${options}    add_argument    disable-notifications
#    Call Method    ${options}    add_argument    disable-logging
#    ${options.binary_location}    Set Variable    ${BROWSER_DIRECTORY}
    ${BrowserOpened}    Run Keyword And Return Status    Open Browser    ${URL}    Chrome    options=${options}
#    ...    executable_path=${CHROMEDRIVER_DIRECTORY}
 #   Set Selenium Timeout    ${DEFAULT_SELENIUM_TIMEOUT}
#    [Return]    ${BrowserOpened}

Fechar Navegador
    [Documentation]    Fecha todos os browsers
    Close All Browsers