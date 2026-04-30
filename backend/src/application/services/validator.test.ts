import {
    validateName,
    validateEmail,
    validatePhone,
    validateDate,
    validateAddress,
    validateCandidateData
} from '../validator';

describe('Validator Tests', () => {
    describe('validateName', () => {
        it('should validate a correct name', () => {
            expect(() => validateName('John Doe')).not.toThrow();
        });

        it('should throw an error for an invalid name', () => {
            expect(() => validateName('')).toThrow('Invalid name');
            expect(() => validateName('J')).toThrow('Invalid name');
            expect(() => validateName('A'.repeat(101))).toThrow('Invalid name');
            expect(() => validateName('John123')).toThrow('Invalid name');
        });
    });

    describe('validateEmail', () => {
        it('should validate a correct email', () => {
            expect(() => validateEmail('john.doe@example.com')).not.toThrow();
        });

        it('should throw an error for an invalid email', () => {
            expect(() => validateEmail('')).toThrow('Invalid email');
            expect(() => validateEmail('john.doe')).toThrow('Invalid email');
            expect(() => validateEmail('john.doe@com')).toThrow('Invalid email');
        });
    });

    describe('validatePhone', () => {
        it('should validate a correct phone number', () => {
            expect(() => validatePhone('612345678')).not.toThrow();
        });

        it('should throw an error for an invalid phone number', () => {
            expect(() => validatePhone('')).not.toThrow();
            expect(() => validatePhone('512345678')).toThrow('Invalid phone');
            expect(() => validatePhone('61234567')).toThrow('Invalid phone');
            expect(() => validatePhone('6123456789')).toThrow('Invalid phone');
        });
    });

    describe('validateDate', () => {
        it('should validate a correct date', () => {
            expect(() => validateDate('2023-01-01')).not.toThrow();
        });

        it('should throw an error for an invalid date', () => {
            expect(() => validateDate('')).toThrow('Invalid date');
            expect(() => validateDate('01-01-2023')).toThrow('Invalid date');
            expect(() => validateDate('2023/01/01')).toThrow('Invalid date');
        });
    });

    describe('validateAddress', () => {
        it('should validate a correct address', () => {
            expect(() => validateAddress('123 Main St')).not.toThrow();
        });

        it('should throw an error for an invalid address', () => {
            expect(() => validateAddress('A'.repeat(101))).toThrow('Invalid address');
        });
    });

    describe('validateCandidateData', () => {
        it('should validate correct candidate data', () => {
            const candidateData = {
                firstName: 'John',
                lastName: 'Doe',
                email: 'john.doe@example.com',
                phone: '612345678',
                address: '123 Main St'
            };
            expect(() => validateCandidateData(candidateData)).not.toThrow();
        });

        it('should throw an error for invalid candidate data', () => {
            const invalidCandidateData = {
                firstName: '',
                lastName: 'Doe',
                email: 'john.doe@example.com',
                phone: '612345678',
                address: '123 Main St'
            };
            expect(() => validateCandidateData(invalidCandidateData)).toThrow('Invalid name');
        });
    });
});
