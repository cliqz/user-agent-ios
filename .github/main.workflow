name: CI
on: [pull_request]
jobs:
  build:
    name: Continuous Intergration
    runs-on: macOS-latest
    steps:
    - uses: actions/checkout@develop
    - name: Use Node.js 9.11.2
      uses: actions/setup-node@v1
      with:
        version: 9.11.2
    - name: Install latest version of npm
      run: npm install -global npm@latest
    - name: Bootstrap
      run: ./bootstrap.sh
