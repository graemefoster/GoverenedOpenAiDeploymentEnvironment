"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const account_data_1 = require("./account-data");
const getAccountDetails = async (accountNumber, res) => {
    const account = account_data_1.accounts.find(a => a.accountNumber === accountNumber);
    if (account !== undefined) {
        console.log(`Returning account ${accountNumber}`);
        return res.send(account);
    }
    console.log(`Could not find account ${accountNumber}`);
    res.sendStatus(404);
};
const getAccountBalance = async (accountNumber, res) => {
    const account = account_data_1.accounts.find(a => a.accountNumber === accountNumber);
    if (account !== undefined) {
        return res.send({
            balance: account.balance,
            asOf: new Date()
        });
    }
    console.log(`Could not find account ${accountNumber}`);
    res.sendStatus(404);
};
const getAccountPayments = async (accountNumber, res) => {
    const account = account_data_1.accounts.find(a => a.accountNumber === accountNumber);
    if (account === undefined) {
        return res.sendStatus(404);
    }
    const accountPayments = account_data_1.payments[accountNumber];
    if (accountPayments !== undefined) {
        console.log(`Returning account payments ${accountNumber}`);
        return res.send(accountPayments);
    }
    console.log(`Could not find account payments ${accountNumber}`);
    return res.send([]);
};
exports.default = { getAccountDetails, getAccountPayments, getAccountBalance };
//# sourceMappingURL=accounts.js.map