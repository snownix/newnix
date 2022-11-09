const statePrefix = '_nx';

module.exports = {
    SaveState: {
        stateKey: null,
        stateName: null,
        mounted() {
            this.stateKey = statePrefix + this.el.getAttribute('id');
            if (!this.stateKey) {
                throw `State key ${this.stateKey} not found !`;
            }

            this.stateName = this.el.getAttribute('name');

            this.el.addEventListener('change', () => {
                this.setState(this.el.value);
            });
        },
        readState() {
            return localStorage.getItem(this.stateKey);
        },
        setState(value) {
            localStorage.setItem(this.stateKey, JSON.stringify({
                name: this.stateName,
                value: value
            }));
        },
        all() {
            let vals = {};

            for (const stateKey in localStorage) {
                try {
                    if (stateKey.startsWith(statePrefix)) {
                        const { name, value } = JSON.parse(localStorage.getItem(stateKey));
                        vals[name] = value;
                    }
                } catch (error) {
                    localStorage.removeItem(stateKey);
                    console.error('Error in parsing save states params');
                }
            }

            return vals;
        }
    }
}