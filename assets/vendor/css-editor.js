import { basicSetup, EditorView } from "codemirror"
import { EditorState, Compartment } from "@codemirror/state"
import { css } from "@codemirror/lang-css"

export default function createCssEditor(el, textarea, cbChanges = () => { }) {
    const language = new Compartment,
        tabSize = new Compartment;

    const state = EditorState.create({
        doc: textarea.value,
        extensions: [
            basicSetup,
            language.of(css()),
            tabSize.of(EditorState.tabSize.of(8)),
            EditorView.updateListener.of((v) => {
                if (v.docChanged) {
                    cbChanges(v.state.doc.toString());
                }
            })
        ]
    });

    const view = new EditorView({
        state: state,
        parent: el,
    });

    return {
        state: state,
        view: view
    };
}