-- Description: Retrieve additional information about a phone number
-- Version: 0.2.0
-- Source: phonenumbers
-- License: GPL-3.0

function run(arg)
    number = url_escape(arg['value'])
    --url = 'https://lookups.twilio.com/v1/PhoneNumbers/' .. number
    url = 'https://lookups.twilio.com/v1/PhoneNumbers/' .. number .. '?Type=carrier&Type=caller-name'

    --debug(json_encode(url))

    session = http_mksession()
    req = http_request(session, 'GET', url, {
        basic_auth={'redacted', 'redacted'},
    })
    reply = http_send(req)
    if last_err() then return end

    if reply['status'] ~= 200 then
        return 'api returned error'
    end

    v = json_decode(reply['text'])
    if last_err() then return end
    debug(json_encode(v))

    update = {}
    update['country'] = v['country_code']

    if v['carrier'] then
        update['carrier'] = v['carrier']['name']
        update['line'] = v['carrier']['type']
    end

    if v['caller_name'] then
        update['caller_name'] = v['caller_name']['caller_name']
        update['caller_type'] = v['caller_name']['caller_type']
    end

    db_update('phonenumber', arg, update)
end
