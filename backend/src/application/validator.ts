const NAME_REGEX = /^[a-zA-ZñÑáéíóúÁÉÍÓÚ ]+$/;
const EMAIL_REGEX = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
const PHONE_REGEX = /^(6|7|9)\d{8}$/;
const DATE_REGEX = /^\d{4}-\d{2}-\d{2}$/;

export const validateName = (name: string) => {
    if (!name || name.length < 2 || name.length > 100 || !NAME_REGEX.test(name)) {
        throw new Error('Invalid name');
    }
};

export const validateEmail = (email: string) => {
    if (!email || !EMAIL_REGEX.test(email)) {
        throw new Error('Invalid email');
    }
};

export const validatePhone = (phone: string) => {
    if (phone && !PHONE_REGEX.test(phone)) {
        throw new Error('Invalid phone');
    }
};

export const validateDate = (date: string) => {
    if (!date || !DATE_REGEX.test(date)) {
        throw new Error('Invalid date');
    }
};

export const validateAddress = (address: string) => {
    if (address && address.length > 100) {
        throw new Error('Invalid address');
    }
};

export const validateCandidateData = (data: any) => {
    if (data.id) {
        return;
    }

    validateName(data.firstName);
    validateName(data.lastName);
    validateEmail(data.email);
    validatePhone(data.phone);
    validateAddress(data.address);
};
