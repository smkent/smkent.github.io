function m_to(event) {
    mt = '&#109;&#097;&#105;&#108;&#116;&#111;:&#115;&#109;&#107;&#101;&#110;&#116;&#064;&#115;&#109;&#107;&#101;&#110;&#116;&#046;&#110;&#101;&#116;'
    document.getElementById('m_to').href = (
        mt.replace(/&#(\d+);/g, function(match, dec) {
            return String.fromCharCode(dec);
        })
    );
}

window.addEventListener('load', m_to);
