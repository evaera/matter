import Link from "@docusaurus/Link";
import useDocusaurusContext from "@docusaurus/useDocusaurusContext";
import Layout from "@theme/Layout";
import clsx from "clsx";
import React from "react";
import "./home.css";
import styles from "./index.module.css";

const FEATURES = [
  {
    image: "https://i.eryn.io/2228/carbon%20%281%29.png",
    title: "Data-Driven Architecture",
    description: (
      <>
        With ECS, your data and your code are separate. Data exists as
        Components, any number of which can be present on an Entity. Systems
        contain your game code and run in a fixed order, every frame. Systems
        query for Entities that have specific Components, and declare what the
        state of the world should be.
        <br />
        <br />
        The separation of state and behavior enables quality of life features
        like Hot Reloading, allowing you to see the changes you've made to your
        code in real time - as soon as you save the file. No need to stop and
        start the game.
      </>
    ),
  },
  {
    image: "https://i.eryn.io/2228/89tcYlOq.png",
    title: "Debug View and Editor",
    description: (
      <>
        Matter comes with a world-class debug view and editor. In addition to
        viewing all your game state in one place, the debugger integrates with
        an immediate-mode widget system to make creating debug conditions dead
        simple. Performance information, queries, logs, and recent errors are
        displayed for each system, enabling deep insight into what your code is
        really doing.
      </>
    ),
  },
  {
    Art: () => (
      <div>
        <div className={styles.event}>
          <p className={styles.frameTitle}>
            All systems run in a fixed order, every frame
          </p>
          <div>
            <h4>RenderStepped</h4>
            <span>moveCutSceneCamera</span>
            <span>animateModels</span>
            <span>camera3dEffects</span>
          </div>
          <div>
            <h4>Heartbeat</h4>
            <span>spawnEnemies</span>
            <span>poisonEnemies</span>
            <span>enemiesMove</span>
            <span>fireWeapons</span>
            <span>doors</span>
          </div>
        </div>
      </div>
    ),
    title: "Robust and Durable",
    description: (
      <>
        Event-driven code can be sensitive to ordering issues and new behaviors
        can be created accidentally. With ECS, your code runs contiguously in a
        fixed order every frame, which makes it much more predictable and
        resilient to new behaviors caused by refactors.
        <br />
        <br />
        All systems have access to all the data in the game, which means adding
        a new feature is as simple as creating a new system that simply declares
        something about the world.
      </>
    ),
  },
];

function Feature({ image, title, description, Art }) {
  return (
    <div className={styles.feature}>
      {image && <img className={styles.featureSvg} alt={title} src={image} />}
      {Art && <Art className={styles.featureSvg} />}
      <div className={styles.featureDescription}>
        <h3>{title}</h3>
        <p>{description}</p>
      </div>
    </div>
  );
}

export function HomepageFeatures() {
  if (!FEATURES) return null;

  return (
    <section>
      <div className="container">
        <div className={styles.features}>
          {FEATURES.map((props, idx) => (
            <Feature key={idx} {...props} />
          ))}
        </div>
      </div>
    </section>
  );
}

function HomepageHeader() {
  const { siteConfig } = useDocusaurusContext();
  return (
    <header className={clsx("hero", styles.heroBanner)}>
      <div className="container">
        <h1 className="hero__title">
          <img
            src={siteConfig.baseUrl + "logo.svg"}
            className="bigLogo"
            alt="Moonwave"
          />
        </h1>
        <p className="hero__subtitle">{siteConfig.tagline}</p>
        <div className={styles.buttons}>
          <Link
            className="button button--secondary button--lg"
            to="/docs/intro"
          >
            Get Started →
          </Link>
        </div>
      </div>
    </header>
  );
}

export default function Home() {
  const { siteConfig, tagline } = useDocusaurusContext();
  return (
    <Layout title={siteConfig.title} description={tagline}>
      <HomepageHeader />
      <main>
        <p className={styles.tagline}>
          Matter is an Entity-Component-System library that empowers developers
          to build games that are extensible, performant, and easy to debug.
        </p>
        <HomepageFeatures />
      </main>
    </Layout>
  );
}
