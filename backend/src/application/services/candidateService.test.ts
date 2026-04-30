import { addCandidate, getCandidateById } from './candidateService';
import { validateCandidateData } from '../validator';
import { Candidate } from '../../domain/models/Candidate';

jest.mock('../validator');
jest.mock('../../domain/models/Candidate');

const MockedCandidate = jest.mocked(Candidate);

describe('CandidateService', () => {
    afterEach(() => {
        jest.resetAllMocks();
    });

    describe('addCandidate', () => {
        it('should validate candidate data', async () => {
            const candidateData = {
                firstName: 'John',
                lastName: 'Doe',
                email: 'john.doe@example.com',
                phone: '612345678',
                address: '123 Main St'
            };

            const mockSave = jest.fn().mockResolvedValue({ id: 1, ...candidateData });
            MockedCandidate.mockImplementation(() => ({
                save: mockSave
            } as any));

            await addCandidate(candidateData);
            expect(validateCandidateData).toHaveBeenCalledWith(candidateData);
        });

        it('should create a new candidate', async () => {
            const candidateData = {
                firstName: 'John',
                lastName: 'Doe',
                email: 'john.doe@example.com',
                phone: '612345678',
                address: '123 Main St'
            };

            const mockSaveCandidate = jest.fn().mockResolvedValue({ id: 1, ...candidateData });

            MockedCandidate.mockImplementation(() => ({
                save: mockSaveCandidate
            } as any));

            const result = await addCandidate(candidateData);
            expect(mockSaveCandidate).toHaveBeenCalled();
            expect(result).toEqual({ id: 1, ...candidateData });
        });

        it('should handle validation errors', async () => {
            const candidateData = {
                firstName: 'John',
                lastName: 'Doe',
                email: 'invalid-email',
                phone: '612345678',
                address: '123 Main St'
            };

            (validateCandidateData as jest.Mock).mockImplementation(() => {
                throw new Error('Invalid email');
            });

            await expect(addCandidate(candidateData)).rejects.toThrow('Invalid email');
        });

        it('should handle database connection errors', async () => {
            const candidateData = {
                firstName: 'John',
                lastName: 'Doe',
                email: 'john.doe@example.com',
                phone: '612345678',
                address: '123 Main St'
            };

            const mockSave = jest.fn().mockRejectedValue(new Error('Database connection error'));
            MockedCandidate.mockImplementation(() => ({
                save: mockSave
            } as any));

            await expect(addCandidate(candidateData)).rejects.toThrow('Database connection error');
        });

        it('should handle unique constraint errors', async () => {
            const candidateData = {
                firstName: 'John',
                lastName: 'Doe',
                email: 'john.doe@example.com',
                phone: '612345678',
                address: '123 Main St'
            };

            const mockSave = jest.fn().mockRejectedValue({ code: 'P2002' });
            MockedCandidate.mockImplementation(() => ({
                save: mockSave
            } as any));

            await expect(addCandidate(candidateData)).rejects.toThrow('The email already exists in the database');
        });
    });

    describe('getCandidateById', () => {
        it('should return candidate information for a valid ID', async () => {
            const candidateId = 1;
            const candidateData = {
                id: candidateId,
                firstName: 'John',
                lastName: 'Doe',
                email: 'john.doe@example.com',
                phone: '612345678',
                address: '123 Main St'
            };

            MockedCandidate.findOne = jest.fn().mockResolvedValue(candidateData);

            const result = await getCandidateById(candidateId);
            expect(MockedCandidate.findOne).toHaveBeenCalledWith(candidateId);
            expect(result).toEqual(candidateData);
        });

        it('should return null if candidate is not found', async () => {
            const candidateId = 1;

            MockedCandidate.findOne = jest.fn().mockResolvedValue(null);

            const result = await getCandidateById(candidateId);
            expect(MockedCandidate.findOne).toHaveBeenCalledWith(candidateId);
            expect(result).toBeNull();
        });

        it('should handle database connection errors', async () => {
            const candidateId = 1;

            MockedCandidate.findOne = jest.fn().mockRejectedValue(new Error('Database connection error'));

            await expect(getCandidateById(candidateId)).rejects.toThrow('Database connection error');
        });
    });
});
