import createCssEditor from '../vendor/css-editor';

const COMPONENT_EVENTS = {
    ADD_ITEM: 'add-item'
};

const statePrefix = '_nx';

module.exports = {
    CssEditor: {
        freeze: false,
        observer: null,
        mounted() {
            const code = this.el.querySelector('code');
            const textarea = this.el.querySelector('textarea');

            createCssEditor(
                code,
                textarea,
                (value) => {
                    textarea.value = value;
                    this.el.dispatchEvent(new Event('change', { bubbles: true }));
                }
            );
        }
    },
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
    },
    InputTags: {
        input: null,
        target: null,
        inputEventName: 'keyup',
        inputEvent: null,
        mounted() {
            this.target = this.el.getAttribute('phx-target');
            this.input = this.el.querySelector('input');

            this.inputEvent = () => {
                const value = this.input.value;

                if (value[value.length - 1] === ",") {
                    this.pushEventTo(this.target, COMPONENT_EVENTS.ADD_ITEM, {
                        v: value.slice(0, -1)
                    });
                    this.input.value = "";
                }
            };

            this.input.addEventListener(this.inputEventName, this.inputEvent);
        },
        destroyed() {
            if (this.input) {
                this.input.removeEventListener(this.inputEventName, this.inputEvent);
            }
        }
    }
}