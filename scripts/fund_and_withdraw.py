from brownie import FundMe
from scripts.utility_scripts import STARTING_PRICE, get_account


def fund():
    fund_me = FundMe[-1]
    account = get_account()
    entrance_fee = fund_me.getEntranceFee()
    test1 = fund_me.getConversionRate(STARTING_PRICE)
    print(f"conversion rate 1: {test1}")
    print(f"get_price: {fund_me.getPrice()}")
    print(f"The current entry fee is: {fund_me.getEntranceFee()}")
    print("Funding")
    fund_me.fund({"from": account, "value": entrance_fee})


def withdraw():
    fund_me = FundMe[-1]
    account = get_account()
    fund_me.withdraw({"from": account})


def main():
    fund()
    withdraw()
