"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.accounts = exports.payments = void 0;
exports.payments = {
    '123456789': [
        {
            amount: 121,
            date: new Date('2023-01-01'),
            payeeRef: 'rent graeme',
            payerRef: 'rent',
            toBsb: '032532',
            toAccount: '5643'
        }
    ]
};
exports.accounts = [
    {
        accountNumber: '123456789',
        balance: 232,
        city: 'Perth',
        name: 'Graeme',
    },
    {
        accountNumber: '2342343',
        balance: 123342,
        city: 'Burnley',
        name: 'Paul'
    },
    {
        accountNumber: '26635765',
        balance: 43434,
        city: 'Sydney',
        name: 'Fred'
    },
    {
        accountNumber: '908348905',
        balance: 534234,
        city: 'Perth',
        name: 'Alice'
    },
];
//# sourceMappingURL=account-data.js.map