import React, {useState, useEffect, useMemo} from "react";
import {useTournaments, useOptions, usePlayers} from "../state";

/**
 * @param {Object} props
 */
export function Options(props) {
    const [tourneys, tourneysDispatch] = useTournaments();
    const [options, optionsDispatch] = useOptions();
    const {playerState, playerDispatch} = usePlayers();
    const [text, setText] = useState("");
    // memoize this so the `useEffect` hook syncs with the correct state
    const exportData = useMemo(
        () => ({options, tourneys, playerState}),
        [options, tourneys, playerState]
    );
    useEffect(
        function () {
            setText(JSON.stringify(exportData, null, 4));
        },
        [exportData]
    );
    /** @param {typeof exportData} data */
    function loadData(data) {
        tourneysDispatch({type: "LOAD_STATE", state: data.tourneys});
        optionsDispatch({type: "LOAD_STATE", state: data.options});
        playerDispatch({type: "LOAD_STATE", state: data.playerState});
        window.alert("Data loaded!");
    }
    /** @param {React.FormEvent<HTMLFormElement>} event */
    function handleText(event) {
        event.preventDefault();
        /** @type {typeof exportData} */
        const importData = JSON.parse(text);
        loadData(importData);
    }
    /** @param {React.ChangeEvent<HTMLInputElement>} event */
    function handleFile(event) {
        event.preventDefault();
        const reader = new FileReader();
        // eslint-disable-next-line fp/no-mutation
        reader.onload = function (ev) {
            /** @type {string} */
            // @ts-ignore
            const data = ev.target.result;
            /** @type {typeof exportData} */
            const importData = JSON.parse(data);
            loadData(importData);
        };
        reader.readAsText(event.currentTarget.files[0]);
        event.currentTarget.value = ""; // so the filename won't linger onscreen
    }
    return (
        <div>
            <form>
                <fieldset>
                    <legend>Bye options</legend>
                    Select how many points a bye is worth:{" "}
                    <label>
                        1
                        <input
                            type="radio"
                            checked={options.byeValue === 1}
                            onChange={() => optionsDispatch({
                                type: "SET_BYE_VALUE",
                                byeValue: 1
                            })}
                        />
                    </label>{" "}
                    <label>
                        ½
                        <input
                            type="radio"
                            checked={options.byeValue === 0.5}
                            onChange={() => optionsDispatch({
                                type: "SET_BYE_VALUE",
                                byeValue: 0.5
                            })}
                        />
                    </label>
                </fieldset>
            </form>
            <fieldset>
                <legend>Manage data</legend>
                <p>
                    <a
                        href={
                            "data:application/json,"
                            + encodeURIComponent(JSON.stringify(exportData))
                        }
                        download="chessahoochee.json"
                    >
                        Download all data
                    </a>
                </p>
                <label>
                    Load data file:{" "}
                    <input type="file" id="file" onChange={handleFile}/>
                </label>
            </fieldset>
            <form onSubmit={handleText}>
                <fieldset>
                    <legend>
                        Advanced: manually edit data
                    </legend>
                    <textarea
                        className="json"
                        rows={25}
                        cols={50}
                        value={text}
                        name="playerdata"
                        onChange={(event) => setText(event.currentTarget.value)}
                    />
                    <p>
                        <input type="submit" value="Load" />
                    </p>
                </fieldset>
            </form>
        </div>
    );
}
