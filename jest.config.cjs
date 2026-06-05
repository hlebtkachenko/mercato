/** @type {import('jest').Config} */
// Standalone Open Mercato app jest config.
// Adapted from the monorepo apps/mercato config: framework packages resolve from
// node_modules (not monorepo source), so the @open-mercato/* path aliases are dropped
// and those packages are transformed (ESM dist -> CJS, import.meta sanitized) instead.
module.exports = {
  testEnvironment: 'node',
  watchman: false,
  rootDir: '.',
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json'],
  moduleNameMapper: {
    '^@/\\.mercato/generated/(.*)$': '<rootDir>/.mercato/generated/$1',
    '^@/generated/(.*)$': '<rootDir>/.mercato/generated/$1',
    '^@/(.*)$': '<rootDir>/src/$1',
  },
  transform: {
    '^.+\\.(t|j)sx?$': [
      '<rootDir>/scripts/jest-mikroorm-transformer.cjs',
      {
        tsconfig: {
          jsx: 'react-jsx',
          rootDir: '.',
          allowJs: true,
        },
      },
    ],
  },
  setupFiles: ['<rootDir>/jest.setup.ts'],
  setupFilesAfterEnv: ['<rootDir>/jest.dom.setup.ts'],
  transformIgnorePatterns: [
    '/node_modules/(?!(@mikro-orm|kysely|meilisearch|@open-mercato)/)',
    '\\.pnp\\.[^\\/]+$',
  ],
  testMatch: ['<rootDir>/src/**/__tests__/**/*.test.(ts|tsx)'],
  passWithNoTests: true,
}
