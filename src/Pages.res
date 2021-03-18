open Belt

module Splash = {
  @react.component
  let make = () =>
    <Window.Body>
      <div className="pages__container">
        <aside className="pages__hint">
          <ol>
            <li className="pages__hint-item">
              <button className="button-primary" onClick={_ => Db.loadDemoDB()}>
                {React.string("Click here to load the demo data")}
              </button>
              {React.string(" (optional)")}
            </li>
            <li className="pages__hint-item">
              <Icons.ArrowLeft /> {React.string(" Select a menu item.")}
            </li>
            <li className="pages__hint-item">
              {React.string("Start creating your tournaments!")}
            </li>
          </ol>
          <Utils.Notification kind=Warning>
            {React.string("If you experience glitches or crashes,")}
            <br />
            {React.string("clear your browser cache and try again.")}
          </Utils.Notification>
        </aside>
        <div className="pages__title">
          <div className="pages__title-icon">
            <img src=Utils.WebpackAssets.logo alt="" height="96" width="96" />
          </div>
          <div className="pages__title-text">
            <h1 className="title" style={ReactDOMRe.Style.make(~fontSize="40px", ())}>
              {React.string("Coronate")}
            </h1>
            <p className={"pages__subtitle caption-30"}> {React.string("Tournament manager")} </p>
          </div>
        </div>
        <footer className={"pages__footer body-20"}>
          <div style={ReactDOMRe.Style.make(~textAlign="left", ())}>
            <p> {React.string("Copyright " ++ (Utils.Entities.copy ++ " 2021 John Jackson."))} </p>
            <p>
              {React.string("Coronate is free software.")}
              <br />
              <a className="pages__footer-link" href=Utils.github_url>
                {React.string("Source code is available")}
              </a>
              {React.string(" under the ")}
              <a className="pages__footer-link" href=Utils.license_url>
                {React.string("AGPL v3.0 license")}
              </a>
              {React.string(".")}
            </p>
          </div>
          <div style={ReactDOMRe.Style.make(~textAlign="right", ())}>
            <p>
              <a className="pages__footer-link" href=Utils.issues_url>
                {React.string("Suggestions and bug reports are welcome.")}
              </a>
            </p>
            <p>
              {React.string("Built with ")}
              <a className="pages__footer-link" href="https://rescript-lang.org/">
                {React.string("ReScript")}
              </a>
              {React.string(" & ")}
              <a className="pages__footer-link" href="https://reactjs.org/">
                {React.string("React")}
              </a>
              {React.string(". ")}
              <span style={ReactDOMRe.Style.make(~fontSize="16px", ())} ariaHidden=true>
                <img
                  src=Utils.WebpackAssets.rescript
                  alt=""
                  height="16"
                  width="16"
                  style={ReactDOMRe.Style.make(~verticalAlign="middle", ())}
                />
                {React.string(" ")}
                <Icons.React />
              </span>
            </p>
          </div>
        </footer>
      </div>
    </Window.Body>
}

let log2 = num => log(num) /. log(2.0)

let fixNumber = num =>
  if num < 0.0 || (num == infinity || num == neg_infinity) {
    0.0
  } else {
    num
  }

module TimeCalculator = {
  let updateFloat = (dispatch, minimum, event) => {
    ReactEvent.Form.preventDefault(event)
    let value =
      ReactEvent.Form.currentTarget(event)["value"]
      ->Float.fromString
      ->Option.getWithDefault(minimum)
    let safeValue = value < minimum ? minimum : value
    dispatch(_ => safeValue)
  }

  let updateInt = (dispatch, minimum, event) => {
    ReactEvent.Form.preventDefault(event)
    let value =
      ReactEvent.Form.currentTarget(event)["value"]->Int.fromString->Option.getWithDefault(minimum)
    let safeValue = value < minimum ? minimum : value
    dispatch(_ => safeValue)
  }

  @react.component
  let make = () => {
    let minPlayers = 0
    let minBreakTime = 0
    let minTotalTime = 0.5
    let (players, setPlayers) = React.useState(() => 2)
    let (breakTime, setBreakTime) = React.useState(() => 5)
    let (totalTime, setTotalTime) = React.useState(() => 4.0)
    <Window.Body>
      <div className="content-area">
        <h1> {React.string("Time calculator")} </h1>
        <p className="caption-30">
          {"Estimate the time requirements for planning your Swiss-style tournament."->React.string}
        </p>
        <form>
          <table style={ReactDOMRe.Style.make(~margin="0", ())}>
            <tbody>
              <tr>
                <td> <label htmlFor="playerCount"> {React.string("Player count ")} </label> </td>
                <td>
                  <input
                    id="playerCount"
                    type_="number"
                    value={Int.toString(players)}
                    onChange={updateInt(setPlayers, minPlayers)}
                    min={Int.toString(minPlayers)}
                    style={ReactDOMRe.Style.make(~width="40px", ())}
                  />
                </td>
              </tr>
              <tr>
                <td> <label> {React.string("Round count")} </label> </td>
                <td> {players->Int.toFloat->log2->ceil->fixNumber->React.float} </td>
              </tr>
              <tr>
                <td>
                  <label htmlFor="breakTime"> {React.string("Breaks between rounds ")} </label>
                </td>
                <td>
                  <input
                    id="breakTime"
                    type_="number"
                    value={Int.toString(breakTime)}
                    onChange={updateInt(setBreakTime, minBreakTime)}
                    step=5.0
                    min={Int.toString(minBreakTime)}
                    style={ReactDOMRe.Style.make(~width="40px", ())}
                  />
                  {React.string(" minutes")}
                </td>
              </tr>
              <tr>
                <td>
                  <label htmlFor="totalTime"> {React.string("Total time available ")} </label>
                </td>
                <td>
                  <input
                    id="totalTime"
                    type_="number"
                    value={Float.toString(totalTime)}
                    onChange={updateFloat(setTotalTime, minTotalTime)}
                    step=0.5
                    min={Float.toString(minTotalTime)}
                    style={ReactDOMRe.Style.make(~width="40px", ())}
                  />
                  {React.string(" hours")}
                </td>
              </tr>
            </tbody>
          </table>
        </form>
        <p className="title-20"> {React.string("Maximum time control: ")} </p>
        <p>
          <span className="title-20">
            {((totalTime *. 60.0 /. players->Int.toFloat->log2->ceil -.
              Int.toFloat(breakTime)) /. 2.0)
            ->ceil
            ->fixNumber
            ->React.float}
            {React.string(" minutes")}
          </span>
          <span className="caption-30">
            {React.string(" = ((")}
            <strong className="monospace"> {totalTime->React.float} </strong>
            {React.string(j` × 60 ÷ ⌈log₂(`)}
            <strong className="monospace"> {players->React.int} </strong>
            {React.string(j`)⌉) - `)}
            <strong className="monospace"> {breakTime->React.int} </strong>
            {React.string(j`) ÷ 2`)}
          </span>
        </p>
      </div>
    </Window.Body>
  }
}

module NotFound = {
  @react.component
  let make = () => <p className="content-area"> {React.string("Page not found.")} </p>
}

/*
 /* Use this in the window footer to indicate unstable releases. */
 module CautionFooter = {
   module Styles = {
     open Css;
     open Utils.PhotonColors;
     let container =
       style([
         width(`percent(100.0)),
         backgroundRepeat(`repeat),
         display(`flex),
         flexDirection(`column),
         justifyContent(`center),
         textAlign(`center),
         alignItems(`center),
         backgroundImage(`url(Utils.WebpackAssets.caution)),
       ]);
     let text =
       style([
         padding(`px(4)),
         backgroundColor(ink_90),
         color(grey_10),
         borderRadius(`px(4)),
       ]);
     let link =
       style([
         color(teal_50),
         visited([color(teal_50)]),
         active([color(teal_60)]),
         focus([color(teal_60)]),
         hover([color(teal_60)]),
       ]);
   };

   [@react.component]
   let make = () =>
     <aside className={Cn.make([Styles.container, "body-20"])}>
       <p className=Styles.text>
         {React.string({j|⚠️|j})}
         {React.string(
            " This is beta software. Want to help make it better? Check out the ",
          )}
         <span role="img" ariaHidden=true> {React.string({j| 👉 |j})} </span>
         {React.string(Utils.Entities.nbsp)}
         <a
           className=Styles.link
           href=Utils.github_url>
           {React.string("Git repository")}
         </a>
         {React.string(".")}
       </p>
     </aside>;
 };
 */
