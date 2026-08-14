(() => {
    "use strict";

    const BRAND = "ReyCloud";
    const THEME_ID = "reycloud-theme";

    function replaceBrandText(root = document.body) {
        if (!root) return;

        const walker = document.createTreeWalker(
            root,
            NodeFilter.SHOW_TEXT
        );

        const nodes = [];

        while (walker.nextNode()) {
            nodes.push(walker.currentNode);
        }

        for (const node of nodes) {
            if (
                !node.nodeValue ||
                !/Pterodactyl/i.test(node.nodeValue)
            ) {
                continue;
            }

            node.nodeValue =
                node.nodeValue.replace(
                    /Pterodactyl/gi,
                    BRAND
                );
        }
    }

    function applyBrand() {
        document.documentElement.dataset.reycloud = "true";

        if (
            document.title &&
            /Pterodactyl/i.test(document.title)
        ) {
            document.title =
                document.title.replace(
                    /Pterodactyl/gi,
                    BRAND
                );
        }

        replaceBrandText();
    }

    function injectStylesheet() {
        if (
            document.getElementById(THEME_ID)
        ) {
            return;
        }

        const link =
            document.createElement("link");

        link.id = THEME_ID;
        link.rel = "stylesheet";
        link.href = "/reycloud/theme.css";

        document.head.appendChild(link);
    }

    function init() {
        injectStylesheet();
        applyBrand();
    }

    if (
        document.readyState === "loading"
    ) {
        document.addEventListener(
            "DOMContentLoaded",
            init,
            { once: true }
        );
    } else {
        init();
    }

    const observer =
        new MutationObserver(() => {
            applyBrand();
        });

    observer.observe(
        document.documentElement,
        {
            childList: true,
            subtree: true
        }
    );
})();
