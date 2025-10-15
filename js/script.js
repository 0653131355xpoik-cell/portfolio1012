const nav = document.querySelector('.nav-links');
const burger = document.querySelector('.burger');

// Drag to scroll on desktop
let isDown = false;
let startX;
let scrollLeft;

if (nav) {
  nav.addEventListener('mousedown', (e) => {
    isDown = true;
    startX = e.pageX - nav.offsetLeft;
    scrollLeft = nav.scrollLeft;
  });

  nav.addEventListener('mouseleave', () => { isDown = false; });
  nav.addEventListener('mouseup', () => { isDown = false; });

  nav.addEventListener('mousemove', (e) => {
    if (!isDown) return;
    e.preventDefault();
    const x = e.pageX - nav.offsetLeft;
    const walk = (x - startX) * 1;
    nav.scrollLeft = scrollLeft - walk;
  });
}

// Mobile: open/close menu via burger
if (burger && nav) {
  burger.addEventListener('click', () => {
    nav.classList.toggle('nav-active');
  });

  // Close menu when a link is clicked
  const links = nav.querySelectorAll('a');
  links.forEach((a) => {
    a.addEventListener('click', () => {
      nav.classList.remove('nav-active');
    });
  });

  // Close when clicking outside the nav on small screens
  document.addEventListener('click', (e) => {
    if (!nav.classList.contains('nav-active')) return;
    const clickedInside = nav.contains(e.target) || burger.contains(e.target);
    if (!clickedInside) nav.classList.remove('nav-active');
  });
}