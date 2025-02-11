$(function () {
    window.addEventListener('message', function (event) {
        if (event.data.type === "openBank") {
            $('#bankui').fadeTo(10, 1.0)
            $("#deposit").removeClass("disabledbutton");
            $("#depositval").removeClass("disabledbutton");
            $('#depositval').val('');
            $('#withdrawval').val('');
        } else if (event.data.type === "closeAll") {
            $('#bankui').fadeTo(10, 0.0)

        } else if (event.data.type === "openAtm") {
            $('#bankui').fadeTo(10, 1.0)
            $("#deposit").addClass("disabledbutton");
            $("#depositval").addClass("disabledbutton");
            $('#depositval').val('');
            $('#withdrawval').val('');
        } else if (event.data.type === "updateBalance") {
            let money = formatter.format(event.data.balance)
            money = money.substring(1)
            $('.balance').html(money);
        }
    });
});

$('#invest').click(function (e) {
    $('bankui').hide();
    $.post('http://tqrp_banking/openInvest', JSON.stringify({}));
});

$('.close').click(function () {
    $('bankui').hide();
    $.post('http://tqrp_banking/NUIFocusOff', JSON.stringify({}));
});

$('#withdraw').click(function (e) {
    e.preventDefault();
    $.post('http://tqrp_banking/withdrawl', JSON.stringify({
        amountw: $('#withdrawval').val()
    }));
    $('#withdrawval').val('');
});

$('#deposit').click(function (e) {
    e.preventDefault();
    $.post('http://tqrp_banking/deposit', JSON.stringify({
        amount: $('#depositval').val()
    }));
    $('#depositval').val('');
});

$('#withdraw-100').click(function (e) {
    e.preventDefault();
    $.post('http://tqrp_banking/withdrawl', JSON.stringify({
        amountw: 100
    }));
});

$('#withdraw-250').click(function (e) {
    e.preventDefault();
    $.post('http://tqrp_banking/withdrawl', JSON.stringify({
        amountw: 250
    }));
});

$('#withdraw-500').click(function (e) {
    e.preventDefault();
    $.post('http://tqrp_banking/withdrawl', JSON.stringify({
        amountw: 500
    }));
});

$('#transfer').click(function (e) {
    e.preventDefault();
    $.post('http://tqrp_banking/transfer', JSON.stringify({
        to: $('#idval').val(),
        amountt: $('#transferval').val()
    }));
    $('#transferval').val('');
});

document.onkeyup = function (data) {
    if (data.which == 27) {
        // $('bankui').hide();
        $('#bankui').fadeTo(10, 0.0)
        $.post('http://tqrp_banking/NUIFocusOff', JSON.stringify({}))
    }
}

var formatter = new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
});