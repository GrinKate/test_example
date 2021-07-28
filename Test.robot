*** Settings ***
Library               RequestsLibrary
Library               SeleniumLibrary
Library               OperatingSystem

*** Variables ***
${Example_report}    Example_report.pdf

*** Test Cases ***
Test Test

#    ${body}    Evaluate    json.loads('{"filter":{"engine_type_code":[],"transmission_code":[],"transmission_drive_code":[],"color_code":[],"body_type_code":[],"label_code":[],"city_id":[],"is_new":null,"rental_car":"exclude_rental"},"per_page":11,"sort_asc":false,"sort_by":"","page":1}')    json
    ${empty_list}    Create List
    ${filter}    Create Dictionary    engine_type_code=${empty_list}    transmission_code=@{EMPTY}    transmission_drive_code=${empty_list}    color_code=${empty_list}    body_type_code=${empty_list}    label_code=${empty_list}    city_id=${empty_list}    is_new=${False}    rental_car=exclude_rental
    ${body_get_cars}    Create Dictionary   filter=${filter}    per_page=${11}    sort_asc=${False}    sort_by=${EMPTY}    page=${1}

#    Create Session    prod    https://api.sberauto.com

    ${resp}    POST    https://api.sberauto.com/searcher/getCars    json=${body_get_cars}

#    ${resp}    POST On Session    prod    /searcher/getCars    json=${body_get_cars}  expected_status=200

    ${uuid}    Set Variable    ${resp.json()}[data][results][0][uuid]

#    ${get_car_body}    Create Dictionary    uuid=${uuid}
#    ${resp}    POST On Session    prod    /searcher/getCar    json=${get_car_body}  expected_status=200
#    Status Should Be                 200  ${resp}

    Log    ${uuid}

    Open Browser    https://sberauto.com/cars/${uuid}    chrome
    Maximize Browser Window

    ${images}    Set Variable    ${resp.json()}[data][results][0][images]

    Log    ${images}

    ${length}    Get Length    ${images}

    Should Be True        ${length}>=${1}   Количество фото в ответе ${length}: меньше 1!

    Wait Until Element Contains    xpath://span[@data-test-id="countAllImages"]    ${length}
    ${all_images_counter}     Get WebElement    xpath://span[@data-test-id="countAllImages"]
    ${text_counter}     Get Text    ${all_images_counter}

    Should Be Equal As Integers    ${length}     ${text_counter}

    FOR    ${image}    IN    @{images}
        Wait Until Page Contains Element    xpath://img[@src='${image}[urls][url_original]']
    END


    ${mask}    Set Variable    *************
    Wait Until Element Contains    xpath://div[@data-test-id="vinMaskByCardAuto"]    ${mask}
    ${vin}    Get WebElement    xpath://div[@data-test-id="vinMaskByCardAuto"]
    ${text_vin}    Get Text    ${vin}
    ${length_vin}    Get Length    ${text_vin}
    Should Be True        ${length_vin}==17

    ${body_get_car}    Create Dictionary   uuid=${uuid}
    ${ans}    POST    https://api.sberauto.com/searcher/getCar    json=${body_get_car}
    ${vin_api}    Set Variable    ${ans.json()}[data][car][vin]
    Should Be Equal    ${vin_api}     ${text_vin}


    ${get_report_xpath}    Set Variable    xpath:(//span[text()='Пример отчета']/ancestor::a)[1]
    Wait Until Page Contains Element    ${get_report_xpath}
    ${link}    Get Element Attribute    ${get_report_xpath}   href
    Log    ${link}
    ${ans_link}    GET    ${link}
    ${ans_ex}    Get Binary File    ${Example_report}
    Should Be Equal    ${ans_link.content}    ${ans_ex}

    [Teardown]    close all browsers



