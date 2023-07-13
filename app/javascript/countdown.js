document.addEventListener('turbo:load', (evt) => {
  const HOUR_SECONDS = 3600;

  const countdowns =
    [...document.getElementsByClassName('b-countdown')];

  function getCountdownBlockHTML(label) {
    return `<div class="b-countdown__${label.toLowerCase()}">${
      getDigitHTML(0)}</div>`;
  }

  function pad(value) {
    if ((`${value}`).length > 1) { return `${value}`; }
    return `0${value}`;
  }

  function getDigitHTML(value) {
    const chars = Array.prototype.map.call(pad(value), (digit) =>
      `<div class="b-countdown__digit">${digit}</div>`,
    );
    return `${chars.join('')
    }<div class="b-countdown__label"></div>`;
  }

  countdowns.forEach((countdown) => {
    countdown.innerHTML =
      getCountdownBlockHTML('Minutes') +
      getCountdownBlockHTML('Seconds');

    // Convert date to browser-friendly value by dropping
    // the timezone portion.
    const targetDate = countdown.dataset.to.
      replace(/-/g, '/').split(' ').slice(0, -1).join(' ');
    const later = new Date(Date.parse(targetDate));
    // After conversion, timezone still applied client-side
    // Sun Apr 14 2030 00:00:00 GMT-0700 (Pacific Daylight Time)

    const minutes =
      countdown.getElementsByClassName('b-countdown__minutes')[0];
    const seconds =
      countdown.getElementsByClassName('b-countdown__seconds')[0];

    const interval = setInterval(() => {
      console.log('interval');
      let remainingValue,
        minutesValue;

      remainingValue = parseInt((later - new Date()) / 1000, 10);

      if (remainingValue > 0) {
        minutesValue = Math.floor(remainingValue / 60);
        remainingValue -= (minutesValue * 60);

        minutes.innerHTML = getDigitHTML(minutesValue);
        seconds.innerHTML = getDigitHTML(remainingValue);
      } else {
        minutes.innerHTML = getDigitHTML(0);
        seconds.innerHTML = getDigitHTML(0);
        clearInterval(interval);
        setInterval(() => {
          countdown.style.opacity = 0;
          setTimeout(() => {
            countdown.style.opacity = 1;
          }, 500);
        }, 1000);
      }
    }, 250);
  });
}, false);
