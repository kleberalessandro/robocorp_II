*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium
Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.PDF
Library             RPA.Archive
Library             RPA.Dialogs
Library             RPA.Robocorp.Vault
Library             OperatingSystem


*** Tasks ***
Orders robots from RobotSpareBin Industries Inc.
    Abrir o site na internet
    Baixar o arquivo do pedido
    Preencher o formulário usando os dados do arquivo csv
    Criar pacote ZIP a partir de arquivos PDF
    [Teardown]    Close Browser



*** Keywords ***
Abrir o site na internet
    ${secret}=    Get Secret    credentials
    Open Available Browser    ${secret}[RobocorpIntranetUrl]    maximized=true

Baixar o arquivo do pedido
    Add text Input    filepath    label=Entre com o caminho do arquivo CSV -Link
    ${result}=    Run Dialog
    Download    ${result.filepath}    overwrite=True

Preencher a opcao da tela
    Wait Until Element Is Visible    //button[text()='OK']
    Click Button    OK

Preencher o formulário usando os dados do arquivo csv
    ${tables}=
    ...    Read Table From Csv
    ...    ${CURDIR}${/}orders.csv
    ...    header=True
    FOR    ${row}    IN    @{tables}
        Preencher a opcao da tela
        Select From List By Value    head    ${row}[Head]
        Select Radio Button    body    ${row}[Body]
        Input Text    //input[@type='number']    ${row}[Legs]
        Input Text    address    ${row}[Address]
        Click Button    //*[@id='preview']
        ${pdf}=    Wait Until Keyword Succeeds
        ...    10x
        ...    0.5s
        ...    Armazenar o recibo como um arquivo PDF
        ...    ${row}[Order number]
        ${screenshot}=    Fazer uma captura de tela do robô    ${row}[Order number]
        Click Button    //*[@id='order-another']
        Carregar a captura de tela do robô ao arquivo PDF do recibo    ${screenshot}    ${pdf}    ${row}[Order number]
    END

Carregar a captura de tela do robô ao arquivo PDF do recibo
    [Arguments]    ${screenshot}    ${pdf}    ${row}
    Open Pdf    ${pdf}
    Add Watermark Image To Pdf    ${screenshot}    ${OUTPUT_DIR}${/}${row}.pdf
    Remove File    ${OUTPUT_DIR}${/}${row}.png

Armazenar o recibo como um arquivo PDF
    [Arguments]    ${row}
    Click Button    //*[@id='order']
    ${receipt_results_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt_results_html}    ${OUTPUT_DIR}${/}${row}.pdf
    RETURN    ${OUTPUT_DIR}${/}${row}.pdf

Fazer uma captura de tela do robô
    [Arguments]    ${row}
    Wait Until Element Is Visible    //div[@id='robot-preview-image']
    Screenshot    //div[@id='robot-preview-image']    ${OUTPUT_DIR}${/}${row}.png
    RETURN    ${OUTPUT_DIR}${/}${row}.png

Criar pacote ZIP a partir de arquivos PDF
    ${zip_file_name}=    Set Variable    ${OUTPUT_DIR}${/}/PDFs.zip
    Archive Folder With Zip    ${OUTPUT_DIR}    ${zip_file_name}    include=*.pdf
    Remove Files    ${OUTPUT_DIR}/*.pdf
