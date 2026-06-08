const THEME_KEY = 'sigma_theme';

export const getTheme = () => {
  return localStorage.getItem(THEME_KEY) || 'dark';
};

export const applyTheme = (theme) => {
  document.body.classList.toggle('theme-light', theme === 'light');
};

export const setTheme = (theme) => {
  localStorage.setItem(THEME_KEY, theme);
  applyTheme(theme);
};
