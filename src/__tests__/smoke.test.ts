// Smoke test: verifies the jest + ts-jest pipeline and setup files load.
// Safe to delete once you have real module tests under src/**/__tests__/*.test.ts.
describe("test harness", () => {
  it("runs TypeScript tests through ts-jest", () => {
    const sum = (a: number, b: number): number => a + b;
    expect(sum(2, 2)).toBe(4);
  });

  it("loads jest.setup.ts env defaults", () => {
    expect(process.env.JWT_SECRET).toBeTruthy();
  });
});
