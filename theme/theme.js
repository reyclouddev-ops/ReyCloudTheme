(() => {
    "use strict";

    const BRAND = "ReyCloud";

    function applyBrand() {
        document.documentElement.dataset.reycloud = "true";

        if (document.title) {
            document.title = document.title
                .replace(/Pterodactyl/gi, BRAND);
        }

        document
            .querySelectorAll("a, span, div")
            .forEach((element) => {
                if (
                    element.childNodes.length === 1 &&
                    element.childNodes[0].nodeType === 3 &&
                    /Pterodactyl/i.test(element.textContent)
                ) {
                    element.textContent =
                        element.textContent.replace(
                            /Pterodactyl/gi,
                            BRAND
                        );
                }
            });
    }

    function inject() {
        if (
            document.querySelector(
                "#reycloud-theme"
            )
        ) {
            return;
        }

        const link =
            document.createElement("link");

        link.id = "reycloud-theme";
        link.rel = "stylesheet";
        link.href =
            "/reycloud/theme.css";

        document.head.appendChild(link);

        applyBrand();
    }

    if (
        document.readyState ===
        "loading"
    ) {
        document.addEventListener(
            "DOMContentLoaded",
            inject
        );
    } else {
        inject();
    }

    new MutationObserver(() => {
        applyBrand();
    }).observe(
        document.documentElement,
        {
            childList: true,
            subtree: true
        }
    );
})();
