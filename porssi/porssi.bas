#include "string.bi"

' *** Game globals ***
const num_companies as integer = 10
dim shared company(num_companies) as string
dim shared freeshares(num_companies) as integer
dim shared ownedshares(num_companies) as integer
dim shared buy(num_companies) as single
dim shared sell(num_companies) as single
dim shared prev_buy(num_companies) as single
dim shared prev_sell(num_companies) as single
dim shared cash as single

' *** Mainloop locals ***
dim i as integer
dim action as string
dim sharetotal as single

declare sub buyshares()
declare sub sellshares()
declare sub nextday()
declare function read_company() as integer
declare function read_shares(minshares as integer, maxshares as integer) as integer

' *** Initialize
randomize

for i = 0 to num_companies - 1
    read company(i), freeshares(i), buy(i), sell(i)
    prev_buy(i) = buy(i)
    prev_sell(i) = sell(i)
    ownedshares(i) = 0
next i    

cash = 10000

' Main gameloop
gameloop:
cls
sharetotal = 0
print "N:o"; tab(5); "Yritys"; tab(30); "Osak."; tab(38); "Omist."; tab(45); "Osto (Muutos)"; tab(65); "Myynti (Muutos)"
for i = 0 to num_companies - 1
    print i + 1; tab(5); company(i); tab(30);
    print format(freeshares(i), "0"); tab(38); format(ownedshares(i), "0"); tab(45);
    print format(buy(i), "0.00");tab(53);
    print format(buy(i)-prev_buy(i), "(0.00)");tab(65);
    print format(sell(i),"0.00");tab(70);
    print format(sell(i)-prev_sell(i), "(0.00)")
    
    sharetotal = sharetotal + ownedshares(i) * sell(i)
next i

print : print
print "Osakkeiden arvo: "; format(sharetotal, "0.00")
print "K‰teist‰: "; format(cash, "0.00")

actionloop:
    locate 20, 1
    print "(O)sta, (M)yy, (S)euraava p‰iv‰"
    action = input(1)
    select case action
    case "o", "O":
        ' *** Buy ***
        buyshares()
    case "m", "M"
        ' *** Sell ***
        sellshares()
    case "s", "S"
        ' *** Next day ***
        nextday()
    case else
        goto actionloop
    end select
    
    goto gameloop
end

sub buyshares()
    dim companyid as integer
    dim numshares_str as string
    dim numshares as integer

    locate 21, 1
    print "Osta osakkeita:"
    companyid = read_company()
    
rereadshares:
    numshares = read_shares(0, freeshares(companyid))
    if cash < numshares * buy(companyid) then
        goto rereadshares
    end if

    ' Make a transaction
    freeshares(companyid) = freeshares(companyid) - numshares
    ownedshares(companyid) = ownedshares(companyid) + numshares
    cash = cash - numshares * buy(companyid)
    
    locate 21,1 
    print space(78)
    print space(78)
    print space(78)
end sub

sub sellshares()
    dim companyid as integer
    dim numshares_str as string
    dim numshares as integer

    locate 21, 1
    print "Myy osakkeita:"
    companyid = read_company()
    
rereadshares:
    numshares = read_shares(0, ownedshares(companyid))

    ' Make a transaction
    freeshares(companyid) = freeshares(companyid) + numshares
    ownedshares(companyid) = ownedshares(companyid) - numshares
    cash = cash + numshares * sell(companyid)
    
    locate 21,1 
    print space(78)
    print space(78)
    print space(78)
end sub


' *** Read company number
function read_company() as integer
    dim companyid_str as string
    dim companyid as integer
rereadcompany:
    locate 22, 1
    print "Yrityksen numero: ";
    line input companyid_str
    companyid = val(companyid_str)
    
    if companyid < 1 or companyid > num_companies then 
        locate 22, 1
        print space(78)
        goto rereadcompany
    end if
    return companyid - 1
end function

' *** Read number of shares
function read_shares(minshares as integer, maxshares as integer) as integer
    dim numshares_str as string
    dim numshares as integer
rereadshares:
    locate 23, 1
    print "Osakkeiden m‰‰r‰: ";
    line input numshares_str
    numshares = val(numshares_str)
    
    if numshares < minshares or numshares > maxshares then 
        locate 23, 1
        print space(78)
        goto rereadshares
    end if
    
    return numshares
end function

' *** Simulate share prices
sub nextday()
    dim i as integer
    dim change as single
    
    for i = 0 to num_companies - 1
        prev_buy(i) = buy(i)
        prev_sell(i) = sell(i)
        
        ' New buy value
        change = rnd() * 3 - 1.5
        buy(i) = buy(i) + change
        
        ' Keep buy price above 1
        if buy(i) < 1 then
            buy(i) = 1 + rnd()
        end if
        
        ' New sell value
        change = rnd() * 3 - 1.5
        sell(i) = sell(i) + change
        
        ' Sell price can't be bigger or equal than buy
        if sell(i) >= buy(i) then
            sell(i) = buy(i) - rnd() - 0.01
        end if
        
        ' Sell price can't be negative nor zero and must be lower than buy price
        if sell(i) < 0.01 or sell(i) >= buy(i) then
            sell(i) = 0.01
        end if
    next i
end sub

' *** companyname, shares, buy price, sell price
DATA "Noware Labs", 1000, 10, 8
DATA "Inf-Coms", 1000, 10, 8
DATA "Sierra Offline", 1000, 10, 8
DATA "Wood Studios", 1000, 10, 8
DATA "Blizzaro Entertainment", 1000, 10, 8
DATA "Sierran", 1000, 10, 8
DATA "Comani", 1000, 10, 8
DATA "Microposers", 1000, 10, 8
DATA "CryTech", 10000, 2.5, 1.25
DATA "Activvision", 5000, 7.25, 5.05

