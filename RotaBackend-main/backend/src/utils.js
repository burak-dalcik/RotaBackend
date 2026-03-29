/** @param {unknown} v */
export function asBool(v) {
  if (v === true || v === 1) return true;
  if (typeof v === 'string') {
    const u = v.trim().toUpperCase();
    return u === 'E' || u === '1' || u === 'TRUE' || u === 'Y' || u === 'EVET';
  }
  return false;
}
